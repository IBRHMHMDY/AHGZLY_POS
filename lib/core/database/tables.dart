// مسار الملف: lib/core/database/tables.dart
// [Refactoring Note]: تم استيراد ملفات الـ Enums لربطها بقاعدة البيانات مباشرة
import 'package:ahgzly_pos/core/database/types_converter.dart';
import 'package:drift/drift.dart';

// ==========================================
// 🗄️ Tables Definition
// ==========================================

/// License Table
@DataClassName('LicenseData')
class License extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isActivated => boolean().withDefault(const Constant(false))();
  TextColumn get licenseKey => text().withDefault(const Constant(""))();
  // [Refactored] تحويل النص إلى DateTime تلقائياً
  TextColumn get trialStartDate => text()
      .map(const DateTimeConverter())
      .withDefault(const Constant("1970-01-01T00:00:00.000"))();
}

/// Settings Table
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

/// Users Table
@DataClassName('UserData')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get pinHash => text()();
  TextColumn get salt => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  TextColumn get lockoutUntil =>
      text().map(const DateTimeConverter()).nullable()();
}

/// Shifts Table
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
  IntColumn get refundedOrdersCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalExpenses => integer().withDefault(const Constant(0))();
  IntColumn get expectedCash => integer().withDefault(const Constant(0))();
  IntColumn get actualCash => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text()(); // إذا كان هناك ShiftStatus Enum في المستقبل، سنضيف له Converter
}

/// Categories Table
@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // [Refactored] تحويل التواريخ
  TextColumn get createdAt => text().map(const DateTimeConverter())();
  TextColumn get updatedAt => text().map(const DateTimeConverter())();
}

/// Products Table
@DataClassName('ItemData')
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  IntColumn get price => integer()();
  IntColumn get costPrice => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text().map(const DateTimeConverter())();
  TextColumn get updatedAt => text().map(const DateTimeConverter())();
}

/// Expenses Table
@DataClassName('ExpenseData')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shiftId => integer().references(Shifts, #id)();
  IntColumn get amount => integer()();
  TextColumn get reason => text()();
  // [Refactored] تحويل التواريخ
  TextColumn get createdAt => text().map(const DateTimeConverter())();
}

/// Orders Table
@DataClassName('OrderData')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  // نوع الطلب: 'dine_in' (صالة), 'takeaway' (تيك أواي), 'delivery' (دليفري)
  TextColumn get orderType => text().map(const OrderTypeConverter()).withDefault(const Constant('takeaway'))();
  IntColumn get shiftId => integer().references(Shifts, #id)();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get tableId =>
      integer().nullable().references(RestaurantTables, #id)();
  IntColumn get subTotal => integer()();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get taxAmount => integer()();
  IntColumn get serviceFee => integer()();
  IntColumn get deliveryFee => integer()();
  IntColumn get total => integer()();
  IntColumn get totalCost => integer().withDefault(const Constant(0))();
  IntColumn get paymentMethodId =>
      integer().nullable().references(PaymentMethods, #id)();
  TextColumn get status => text().map(const OrderStatusConverter())();
  TextColumn get customerName => text().withDefault(const Constant(""))();
  TextColumn get customerPhone => text().withDefault(const Constant(""))();
  TextColumn get customerAddress => text().withDefault(const Constant(""))();
  TextColumn get createdAt => text().map(const DateTimeConverter())();
}

// Order Products Table
@DataClassName('OrderItemsData')
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get itemId => integer().references(Items, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitPrice => integer()();
  IntColumn get unitCostPrice => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
}

/// Customers Table
@DataClassName('CustomerData')
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get phone => text().nullable().withLength(min: 10, max: 20)();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Zones Table
@DataClassName('ZoneData')
class Zones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name =>
      text().withLength(min: 2, max: 50)(); // مثال: صالة 1، التراس، الحديقة
}

/// RestaurantTables Table
@DataClassName('RestaurantTableData')
class RestaurantTables extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get zoneId => integer().references(Zones, #id)();
  TextColumn get tableNumber => text().withLength(min: 1, max: 10)();
  IntColumn get capacity => integer().withDefault(const Constant(4))();
  TextColumn get status => text().withDefault(
    const Constant('available'),
  )(); // available, occupied, reserved
}

/// PaymentMethod Table
@DataClassName('PaymentMethodData')
class PaymentMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name =>
      text().withLength(min: 2, max: 50)(); // كاش، فيزا، فودافون كاش
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

/// ItemVariants Table
@DataClassName('ItemVariantData')
class ItemVariants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(Items, #id)();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  // 💰 الأموال تم تحويلها إلى Integer
  IntColumn get price => integer()();
  IntColumn get costPrice => integer().withDefault(const Constant(0))();
}

/// Addons Table
@DataClassName('AddonData')
class Addons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get price => integer()();
  IntColumn get costPrice => integer().withDefault(const Constant(0))();
}

/// InventoryItems Table
@DataClassName('InventoryItemData')
class InventoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get unit => text().withLength(min: 1, max: 20)(); // جم، مل، قطعة
  RealColumn get stockQuantity =>
      real().withDefault(const Constant(0.0))(); // الكميات تبقى Real
  IntColumn get costPerUnit => integer().withDefault(const Constant(0))();
}

/// Recipes Table
@DataClassName('RecipeData')
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().nullable().references(Items, #id)();
  IntColumn get variantId =>
      integer().nullable().references(ItemVariants, #id)();
  IntColumn get inventoryItemId => integer().references(InventoryItems, #id)();
  RealColumn get quantityNeeded => real()();
}
