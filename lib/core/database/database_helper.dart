import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ahgzly_pos/core/utils/hash_util.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_sys.db');

    return await openDatabase(
      path,
      version: 12, // الترقية إلى 12 لإضافة قيود الورديات والفهارس (Indexes)
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // فرض صارم لسلامة العلاقات (Foreign Keys) على مستوى الـ SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. جداول النظام الأساسية
    await db.execute('''
      CREATE TABLE license (
        id INTEGER PRIMARY KEY DEFAULT 1, 
        is_activated INTEGER NOT NULL DEFAULT 0, 
        license_key TEXT NOT NULL DEFAULT "", 
        trial_start_date TEXT NOT NULL DEFAULT ""
      )
    ''');
    await db.insert('license', {'id': 1, 'is_activated': 0, 'trial_start_date': DateTime.now().toIso8601String()});

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY DEFAULT 1, 
        tax_rate REAL NOT NULL, 
        service_rate REAL NOT NULL, 
        delivery_fee REAL NOT NULL, 
        printer_name TEXT NOT NULL, 
        restaurant_name TEXT NOT NULL, 
        tax_number TEXT NOT NULL, 
        print_mode TEXT NOT NULL
      )
    ''');
    await db.insert('settings', {'id': 1, 'tax_rate': 0.14, 'service_rate': 0.12, 'delivery_fee': 20.0, 'printer_name': 'EPSON Printer', 'restaurant_name': 'مـطـعـم احـجـزلـي', 'tax_number': '123-456-789', 'print_mode': 'ask'});

    // 2. جداول الموارد البشرية والمستخدمين
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT NOT NULL, 
        pin_hash TEXT NOT NULL, 
        salt TEXT NOT NULL, 
        role TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        failed_attempts INTEGER NOT NULL DEFAULT 0,
        lockout_until TEXT
      )
    ''');
    
    final adminSalt = HashUtil.generateSalt();
    final adminHashedPin = HashUtil.generatePinHash('123456', adminSalt); 
    final cashierSalt = HashUtil.generateSalt();
    final cashierHashedPin = HashUtil.generatePinHash('000000', cashierSalt);
    
    await db.insert('users', {'name': 'مدير النظام', 'pin_hash': adminHashedPin, 'salt': adminSalt, 'role': 'admin', 'is_active': 1});
    await db.insert('users', {'name': 'كاشير 1', 'pin_hash': cashierHashedPin, 'salt': cashierSalt, 'role': 'cashier', 'is_active': 1});

    // 3. جدول الورديات (Shifts)
    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        cashier_id INTEGER,
        start_time TEXT NOT NULL, 
        end_time TEXT, 
        starting_cash REAL NOT NULL DEFAULT 0.0,
        total_sales REAL NOT NULL DEFAULT 0.0,
        total_cash REAL NOT NULL DEFAULT 0.0, 
        total_visa REAL NOT NULL DEFAULT 0.0, 
        total_instapay REAL NOT NULL DEFAULT 0.0,
        total_orders INTEGER NOT NULL DEFAULT 0,
        total_expenses REAL NOT NULL DEFAULT 0.0,
        expected_cash REAL NOT NULL DEFAULT 0.0,
        actual_cash REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL,
        FOREIGN KEY (cashier_id) REFERENCES users (id) ON DELETE RESTRICT
      )
    ''');

    // 4. جداول المنتجات والأقسام
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT NOT NULL, 
        created_at TEXT NOT NULL, 
        updated_at TEXT NOT NULL
      )
    ''');
    
    // تعديل: ON DELETE RESTRICT بدلاً من CASCADE لمنع مسح قسم به منتجات عن طريق الخطأ
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        category_id INTEGER NOT NULL, 
        name TEXT NOT NULL, 
        price REAL NOT NULL, 
        created_at TEXT NOT NULL, 
        updated_at TEXT NOT NULL, 
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');

    // 5. جداول الحركات المالية (المبيعات والمصروفات) - تم ربطها بالوردية
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        shift_id INTEGER NOT NULL,
        amount REAL NOT NULL, 
        reason TEXT NOT NULL, 
        created_at TEXT NOT NULL,
        FOREIGN KEY (shift_id) REFERENCES shifts (id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        shift_id INTEGER NOT NULL,
        order_type TEXT NOT NULL, 
        sub_total REAL NOT NULL, 
        discount REAL NOT NULL DEFAULT 0.0, 
        tax_amount REAL NOT NULL, 
        service_fee REAL NOT NULL, 
        delivery_fee REAL NOT NULL, 
        total REAL NOT NULL, 
        payment_method TEXT NOT NULL, 
        status TEXT NOT NULL, 
        customer_name TEXT DEFAULT "", 
        customer_phone TEXT DEFAULT "", 
        customer_address TEXT DEFAULT "", 
        created_at TEXT NOT NULL,
        FOREIGN KEY (shift_id) REFERENCES shifts (id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        order_id INTEGER NOT NULL, 
        item_id INTEGER NOT NULL, 
        quantity INTEGER NOT NULL, 
        unit_price REAL NOT NULL, 
        notes TEXT, 
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE, 
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE RESTRICT
      )
    ''');

    // 6. إنشاء الفهارس (Indexes) لتحسين أداء التقارير بشكل جذري
    await db.execute('CREATE INDEX idx_items_category ON items(category_id)');
    await db.execute('CREATE INDEX idx_orders_shift ON orders(shift_id)');
    await db.execute('CREATE INDEX idx_orders_created_at ON orders(created_at)');
    await db.execute('CREATE INDEX idx_expenses_shift ON expenses(shift_id)');
    await db.execute('CREATE INDEX idx_shifts_status ON shifts(status)');
  }

  /// دالة مساعدة لفحص ما إذا كان العمود موجوداً بالفعل في الجدول لتجنب أعطال الترقية
  Future<bool> _columnExists(Database db, String tableName, String columnName) async {
    final result = await db.rawQuery("PRAGMA table_info($tableName)");
    return result.any((row) => row['name'] == columnName);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 11) {
      // ترقيات قديمة (محمية الآن بفحص مسبق)
      if (!await _columnExists(db, 'shifts', 'cashier_id')) {
        await db.execute('ALTER TABLE shifts ADD COLUMN cashier_id INTEGER DEFAULT 1');
      }
      if (!await _columnExists(db, 'shifts', 'starting_cash')) {
        await db.execute('ALTER TABLE shifts ADD COLUMN starting_cash REAL DEFAULT 0.0');
      }
      if (!await _columnExists(db, 'shifts', 'total_expenses')) {
        await db.execute('ALTER TABLE shifts ADD COLUMN total_expenses REAL DEFAULT 0.0');
      }
      if (!await _columnExists(db, 'shifts', 'expected_cash')) {
        await db.execute('ALTER TABLE shifts ADD COLUMN expected_cash REAL DEFAULT 0.0');
      }
      if (!await _columnExists(db, 'shifts', 'actual_cash')) {
        await db.execute('ALTER TABLE shifts ADD COLUMN actual_cash REAL DEFAULT 0.0');
      }
    }
    
    if (oldVersion < 12) {
      // 1. إضافة shift_id للجداول بأمان تام (لن يحدث كراش إذا كان موجوداً)
      if (!await _columnExists(db, 'orders', 'shift_id')) {
        await db.execute('ALTER TABLE orders ADD COLUMN shift_id INTEGER DEFAULT 0');
      }
      if (!await _columnExists(db, 'expenses', 'shift_id')) {
        await db.execute('ALTER TABLE expenses ADD COLUMN shift_id INTEGER DEFAULT 0');
      }
      
      // 2. إنشاء الفهارس
      await db.execute('CREATE INDEX IF NOT EXISTS idx_items_category ON items(category_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_orders_shift ON orders(shift_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_shift ON expenses(shift_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_shifts_status ON shifts(status)');
    }
  }
}