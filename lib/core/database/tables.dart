// مسار الملف: lib/core/database/tables.dart
// [Refactoring Note]: تم استيراد ملفات الـ Enums لربطها بقاعدة البيانات مباشرة
import 'package:ahgzly_pos/core/database/types_converter.dart';
import 'package:drift/drift.dart';

// ==========================================
// 🗄️ Tables Definition
// ==========================================

// 1. جدول الترخيص
@DataClassName('LicenseData')
class License extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isValid => boolean().withDefault(const Constant(false))();
  TextColumn get licenseKey => text().withDefault(const Constant(""))();
  TextColumn get expiryDate => text().map(const DateTimeConverter()).nullable()();
  TextColumn get deviceId => text().nullable()();
}

// 2. جدول الإعدادات
@DataClassName('SettingsData')
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get taxRate => real()();
  RealColumn get serviceRate => real()();
  IntColumn get deliveryFee => integer()();
  TextColumn get printerName => text()();
  TextColumn get restaurantName => text()();
  TextColumn get taxNumber => text()();
  TextColumn get printMode => text()();
}

// 3. جدول المستخدمين
@DataClassName('UserData')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get pinHash => text()();
  TextColumn get salt => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  TextColumn get lockoutUntil => text().map(const DateTimeConverter()).nullable()();
}

// 4. جدول الورديات
@DataClassName('ShiftData')
class Shifts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cashierId => integer().nullable().references(Users, #id)();
  TextColumn get startTime => text().map(const DateTimeConverter())();
  TextColumn get endTime => text().map(const DateTimeConverter()).nullable()();
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
@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get createdAt => text().map(const DateTimeConverter())();
  TextColumn get updatedAt => text().map(const DateTimeConverter())();
}

@DataClassName('ItemData')
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  IntColumn get price => integer()(); 
  // [Refactored]: إضافة حقل التكلفة (بالسنت) لحساب الأرباح لاحقاً
  IntColumn get cost => integer().withDefault(const Constant(0))(); 
  TextColumn get createdAt => text().map(const DateTimeConverter())();
  TextColumn get updatedAt => text().map(const DateTimeConverter())();
}

// 7. جدول المصروفات
@DataClassName('ExpenseData')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shiftId => integer().references(Shifts, #id)();
  IntColumn get amount => integer()(); 
  TextColumn get reason => text()();
  // [Refactored] تحويل التواريخ
  TextColumn get createdAt => text().map(const DateTimeConverter())();
}

// 8. جدول الطلبات
@DataClassName('OrderData')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shiftId => integer().references(Shifts, #id)();
  // [Refactored] ربط الـ Enums مباشرة بالأعمدة
  TextColumn get orderType => text().map(const OrderTypeConverter())();
  IntColumn get tableId => integer().nullable()();
  IntColumn get subTotal => integer()();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get netSales => integer().withDefault(const Constant(0))(); 
  IntColumn get taxAmount => integer()();
  IntColumn get serviceFee => integer()();
  IntColumn get deliveryFee => integer()();
  IntColumn get totalCost => integer().withDefault(const Constant(0))(); 
  IntColumn get total => integer()();
  TextColumn get paymentMethod => text().map(const PaymentMethodConverter())();
  TextColumn get status => text().map(const OrderStatusConverter())();
  TextColumn get customerName => text().withDefault(const Constant(""))();
  TextColumn get customerPhone => text().withDefault(const Constant(""))();
  TextColumn get customerAddress => text().withDefault(const Constant(""))();
  TextColumn get createdAt => text().map(const DateTimeConverter())();
}

// 9. جدول عناصر الطلب
@DataClassName('OrderItemsData')
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)(); 
  IntColumn get itemId => integer().references(Items, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitPrice => integer()(); 
  IntColumn get unitCost => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
}