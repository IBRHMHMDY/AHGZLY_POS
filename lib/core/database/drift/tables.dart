// مسار الملف: lib/core/database/drift/tables.dart

import 'package:drift/drift.dart';

// 1. جدول الترخيص
class LicenseTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isActivated => boolean().withDefault(const Constant(false))();
  TextColumn get licenseKey => text().withDefault(const Constant(""))();
  TextColumn get trialStartDate => text().withDefault(const Constant(""))();
}

// 2. جدول الإعدادات
class SettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get taxRate => real()();
  RealColumn get serviceRate => real()();
  IntColumn get deliveryFee => integer()(); // بالسنت (Cents)
  TextColumn get printerName => text()();
  TextColumn get restaurantName => text()();
  TextColumn get taxNumber => text()();
  TextColumn get printMode => text()();
}

// 3. جدول المستخدمين
class UsersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get pinHash => text()();
  TextColumn get salt => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  TextColumn get lockoutUntil => text().nullable()();
}

// 4. جدول الورديات
class ShiftsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cashierId => integer().nullable().references(UsersTable, #id)();
  TextColumn get startTime => text()();
  TextColumn get endTime => text().nullable()();
  IntColumn get startingCash => integer().withDefault(const Constant(0))();
  IntColumn get totalSales => integer().withDefault(const Constant(0))();
  IntColumn get totalCash => integer().withDefault(const Constant(0))();
  IntColumn get totalVisa => integer().withDefault(const Constant(0))();
  IntColumn get totalInstapay => integer().withDefault(const Constant(0))();
  IntColumn get totalOrders => integer().withDefault(const Constant(0))();
  IntColumn get totalRefunds => integer().withDefault(const Constant(0))();
  IntColumn get refundedOrdersCount => integer().withDefault(const Constant(0))();
  IntColumn get totalExpenses => integer().withDefault(const Constant(0))();
  IntColumn get expectedCash => integer().withDefault(const Constant(0))();
  IntColumn get actualCash => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
}

// 5. جدول الأقسام
class CategoriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

// 6. جدول المنتجات
class ItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(CategoriesTable, #id)();
  TextColumn get name => text()();
  IntColumn get price => integer()(); // بالسنت (Cents)
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

// 7. جدول المصروفات
class ExpensesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shiftId => integer().references(ShiftsTable, #id)();
  IntColumn get amount => integer()(); // بالسنت (Cents)
  TextColumn get reason => text()();
  TextColumn get createdAt => text()();
}

// 8. جدول الطلبات
class OrdersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shiftId => integer().references(ShiftsTable, #id)();
  TextColumn get orderType => text()();
  IntColumn get subTotal => integer()(); // بالسنت
  IntColumn get discount => integer().withDefault(const Constant(0))(); // بالسنت
  IntColumn get taxAmount => integer()(); // بالسنت
  IntColumn get serviceFee => integer()(); // بالسنت
  IntColumn get deliveryFee => integer()(); // بالسنت
  IntColumn get total => integer()(); // بالسنت
  TextColumn get paymentMethod => text()();
  TextColumn get status => text()();
  TextColumn get customerName => text().withDefault(const Constant(""))();
  TextColumn get customerPhone => text().withDefault(const Constant(""))();
  TextColumn get customerAddress => text().withDefault(const Constant(""))();
  TextColumn get createdAt => text()();
}

// 9. جدول عناصر الطلب
class OrderItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(OrdersTable, #id)(); // Cascade Delete سيتم إدارته عبر Drift
  IntColumn get itemId => integer().references(ItemsTable, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitPrice => integer()(); // بالسنت
  TextColumn get notes => text().nullable()();
}