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

    return await openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, category_id INTEGER NOT NULL, name TEXT NOT NULL, price REAL NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE)''');
    await db.execute('''CREATE TABLE orders (id INTEGER PRIMARY KEY AUTOINCREMENT, order_type TEXT NOT NULL, sub_total REAL NOT NULL, discount REAL NOT NULL DEFAULT 0.0, tax_amount REAL NOT NULL, service_fee REAL NOT NULL, delivery_fee REAL NOT NULL, total REAL NOT NULL, payment_method TEXT NOT NULL, status TEXT NOT NULL, customer_name TEXT DEFAULT "", customer_phone TEXT DEFAULT "", customer_address TEXT DEFAULT "", created_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE order_items (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL, item_id INTEGER NOT NULL, quantity INTEGER NOT NULL, unit_price REAL NOT NULL, notes TEXT, FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE, FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE)''');
    await db.execute('''CREATE TABLE shifts (id INTEGER PRIMARY KEY AUTOINCREMENT, start_time TEXT NOT NULL, end_time TEXT NOT NULL, total_cash REAL NOT NULL, total_visa REAL NOT NULL, total_sales REAL NOT NULL, status TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE settings (id INTEGER PRIMARY KEY DEFAULT 1, tax_rate REAL NOT NULL, service_rate REAL NOT NULL, delivery_fee REAL NOT NULL, printer_name TEXT NOT NULL, restaurant_name TEXT NOT NULL, tax_number TEXT NOT NULL, print_mode TEXT NOT NULL)''');
    await db.insert('settings', {'id': 1, 'tax_rate': 0.14, 'service_rate': 0.12, 'delivery_fee': 20.0, 'printer_name': 'EPSON Printer', 'restaurant_name': 'مـطـعـم احـجـزلـي', 'tax_number': '123-456-789', 'print_mode': 'ask'});
    await db.execute('''CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, pin TEXT NOT NULL UNIQUE, role TEXT NOT NULL)''');
    await db.insert('users', {'name': 'مدير النظام', 'pin': '1234', 'role': 'admin'});
    await db.insert('users', {'name': 'كاشير 1', 'pin': '0000', 'role': 'cashier'});
    await db.execute('''CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, reason TEXT NOT NULL, created_at TEXT NOT NULL)''');
    
    // جدول حماية النسخة
    await db.execute('''CREATE TABLE license (id INTEGER PRIMARY KEY DEFAULT 1, is_activated INTEGER NOT NULL DEFAULT 0, license_key TEXT NOT NULL DEFAULT "")''');
    await db.insert('license', {'id': 1, 'is_activated': 0});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ... الترقيات السابقة
    if (oldVersion < 2) { await db.execute('''CREATE TABLE IF NOT EXISTS settings (id INTEGER PRIMARY KEY DEFAULT 1, tax_rate REAL NOT NULL, service_rate REAL NOT NULL, delivery_fee REAL NOT NULL, printer_name TEXT NOT NULL)'''); await db.insert('settings', {'id': 1, 'tax_rate': 0.14, 'service_rate': 0.12, 'delivery_fee': 20.0, 'printer_name': 'EPSON Printer'}); }
    if (oldVersion < 3) { await db.execute('''CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, pin TEXT NOT NULL UNIQUE, role TEXT NOT NULL)'''); await db.insert('users', {'name': 'مدير النظام', 'pin': '1234', 'role': 'admin'}); await db.insert('users', {'name': 'كاشير 1', 'pin': '0000', 'role': 'cashier'}); }
    if (oldVersion < 4) { await db.execute('ALTER TABLE settings ADD COLUMN restaurant_name TEXT DEFAULT "مـطـعـم احـجـزلـي"'); await db.execute('ALTER TABLE settings ADD COLUMN tax_number TEXT DEFAULT "123-456-789"'); }
    if (oldVersion < 5) { await db.execute('ALTER TABLE settings ADD COLUMN print_mode TEXT DEFAULT "ask"'); }
    if (oldVersion < 6) { await db.execute('ALTER TABLE orders ADD COLUMN discount REAL DEFAULT 0.0'); }
    if (oldVersion < 7) { await db.execute('ALTER TABLE orders ADD COLUMN customer_name TEXT DEFAULT ""'); await db.execute('ALTER TABLE orders ADD COLUMN customer_phone TEXT DEFAULT ""'); await db.execute('ALTER TABLE orders ADD COLUMN customer_address TEXT DEFAULT ""'); await db.execute('''CREATE TABLE IF NOT EXISTS expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, reason TEXT NOT NULL, created_at TEXT NOT NULL)'''); }
    
    if (oldVersion < 8) {
      await db.execute('''CREATE TABLE IF NOT EXISTS license (id INTEGER PRIMARY KEY DEFAULT 1, is_activated INTEGER NOT NULL DEFAULT 0, license_key TEXT NOT NULL DEFAULT "")''');
      await db.insert('license', {'id': 1, 'is_activated': 0});
    }
  }
}