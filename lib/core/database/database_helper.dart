import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

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
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ahgzly_pos.db');

    // تم رفع الإصدار إلى 2 لإنشاء جدول الإعدادات
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_type TEXT NOT NULL,
        sub_total REAL NOT NULL,
        tax_amount REAL NOT NULL,
        service_fee REAL NOT NULL,
        delivery_fee REAL NOT NULL,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
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
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        total_cash REAL NOT NULL,
        total_visa REAL NOT NULL,
        total_sales REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // جدول الإعدادات
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        tax_rate REAL NOT NULL,
        service_rate REAL NOT NULL,
        delivery_fee REAL NOT NULL,
        printer_name TEXT NOT NULL
      )
    ''');

    // إدخال القيم الافتراضية للإعدادات
    await db.insert('settings', {
      'id': 1,
      'tax_rate': 0.14,
      'service_rate': 0.12,
      'delivery_fee': 20.0,
      'printer_name': 'EPSON Printer',
    });
  }

  // دالة الترقية (تعمل فقط للمستخدمين الذين لديهم الإصدار 1)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          id INTEGER PRIMARY KEY DEFAULT 1,
          tax_rate REAL NOT NULL,
          service_rate REAL NOT NULL,
          delivery_fee REAL NOT NULL,
          printer_name TEXT NOT NULL
        )
      ''');
      
      // إدخال القيم الافتراضية للإعدادات
      await db.insert('settings', {
        'id': 1,
        'tax_rate': 0.14,
        'service_rate': 0.12,
        'delivery_fee': 20.0,
        'printer_name': 'EPSON Printer',
      });
    }
  }
}