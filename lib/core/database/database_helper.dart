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
    final path = join(dbPath, 'ahgzly_pos.db');

    return await openDatabase(
      path,
      version: 11, // تم الترقية إلى 11 لدعم حقول الوردية المتقدمة
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, category_id INTEGER NOT NULL, name TEXT NOT NULL, price REAL NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE)''');
    await db.execute('''CREATE TABLE orders (id INTEGER PRIMARY KEY AUTOINCREMENT, order_type TEXT NOT NULL, sub_total REAL NOT NULL, discount REAL NOT NULL DEFAULT 0.0, tax_amount REAL NOT NULL, service_fee REAL NOT NULL, delivery_fee REAL NOT NULL, total REAL NOT NULL, payment_method TEXT NOT NULL, status TEXT NOT NULL, customer_name TEXT DEFAULT "", customer_phone TEXT DEFAULT "", customer_address TEXT DEFAULT "", created_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE order_items (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL, item_id INTEGER NOT NULL, quantity INTEGER NOT NULL, unit_price REAL NOT NULL, notes TEXT, FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE, FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE)''');
    
    // الهيكل التجاري لجدول الورديات
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
        status TEXT NOT NULL
      )
    ''');
    
    await db.execute('''CREATE TABLE settings (id INTEGER PRIMARY KEY DEFAULT 1, tax_rate REAL NOT NULL, service_rate REAL NOT NULL, delivery_fee REAL NOT NULL, printer_name TEXT NOT NULL, restaurant_name TEXT NOT NULL, tax_number TEXT NOT NULL, print_mode TEXT NOT NULL)''');
    await db.insert('settings', {'id': 1, 'tax_rate': 0.14, 'service_rate': 0.12, 'delivery_fee': 20.0, 'printer_name': 'EPSON Printer', 'restaurant_name': 'مـطـعـم احـجـزلـي', 'tax_number': '123-456-789', 'print_mode': 'ask'});
    
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
    
    await db.insert('users', {
      'name': 'مدير النظام', 
      'pin_hash': adminHashedPin, 
      'salt': adminSalt,
      'role': 'admin',
      'is_active': 1
    });
    await db.insert('users', {
      'name': 'كاشير 1', 
      'pin_hash': cashierHashedPin, 
      'salt': cashierSalt,
      'role': 'cashier',
      'is_active': 1
    });
    
    await db.execute('''CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, reason TEXT NOT NULL, created_at TEXT NOT NULL)''');
    
    await db.execute('''CREATE TABLE license (id INTEGER PRIMARY KEY DEFAULT 1, is_activated INTEGER NOT NULL DEFAULT 0, license_key TEXT NOT NULL DEFAULT "", trial_start_date TEXT NOT NULL DEFAULT "")''');
    await db.insert('license', {'id': 1, 'is_activated': 0, 'trial_start_date': DateTime.now().toIso8601String()});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ... تحديثاتك القديمة من 1 إلى 10 توضع هنا ...
    
    if (oldVersion < 11) {
      // الترقية للنسخة التجارية من الوردية
      await db.execute('ALTER TABLE shifts ADD COLUMN cashier_id INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE shifts ADD COLUMN starting_cash REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE shifts ADD COLUMN total_expenses REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE shifts ADD COLUMN expected_cash REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE shifts ADD COLUMN actual_cash REAL DEFAULT 0.0');
    }
  }
}