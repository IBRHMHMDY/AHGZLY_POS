import 'dart:io';
import 'package:ahgzly_pos/core/database/types_converter.dart';
import 'package:ahgzly_pos/core/extensions/order_status.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:ahgzly_pos/core/utils/hash_util.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart'; 

@DriftDatabase(tables: [
  // الجداول القديمة
  License, Settings, Users, Shifts, Categories, 
  Items, Expenses, Orders, OrderItems,
  
  // 🚀 الجداول المضافة في Sprint 1 (تعريفها يحل مشكلة الـ Migration)
  Customers, Zones, RestaurantTables, PaymentMethods,
  
  // 🚀 الجداول المضافة في Sprint 2 (تعريفها يحل مشكلة Undefined name)
  ItemVariants, Addons, InventoryItems, Recipes, OrderItemAddons
])

class AppDatabase extends _$AppDatabase {
  
  // Refactored: Accept QueryExecutor to allow dependency injection (e.g., In-Memory DB for testing)
  AppDatabase(super.e);

  @override
  int get schemaVersion => 18; 

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Insert default initial data
        await into(license).insert(
          LicenseCompanion.insert(
            isActivated: const Value(false),
            trialStartDate: Value(DateTime.now()),
          ),
        );

        await into(settings).insert(
          SettingsCompanion.insert(
            taxRate: 0.14,
            serviceRate: 0.12,
            deliveryFee: 2000,
            printerName: 'EPSON Printer',
            restaurantName: 'مـطـعـم احـجـزلـي',
            taxNumber: '123-456-789',
            printMode: 'ask',
          ),
        );

        final adminSalt = HashUtil.generateSalt();
        final adminHashedPin = HashUtil.generatePinHash('123456', adminSalt); 
        final cashierSalt = HashUtil.generateSalt();
        final cashierHashedPin = HashUtil.generatePinHash('000000', cashierSalt);

        await into(users).insert(
          UsersCompanion.insert(
            name: 'مدير النظام',
            pinHash: adminHashedPin,
            salt: adminSalt,
            role: 'admin',
            isActive: const Value(true),
          ),
        );

        await into(users).insert(
          UsersCompanion.insert(
            name: 'كاشير 1',
            pinHash: cashierHashedPin,
            salt: cashierSalt,
            role: 'cashier',
            isActive: const Value(true),
          ),
        );

        await into(paymentMethods).insert(PaymentMethodsCompanion.insert(name: 'كاش'));
        await into(paymentMethods).insert(PaymentMethodsCompanion.insert(name: 'بطاقة إئتمان (فيزا / مدى)'));
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 15) {
          // إضافة الأعمدة الجديدة للجداول القديمة بدون مسح بيانات العميل
          await m.addColumn(items, items.costPrice);
          await m.addColumn(orders, orders.totalCost);
          await m.addColumn(orderItems, orderItems.unitCostPrice);
        }

        if (from < 16) {
          // 1. إنشاء الجداول الجديدة
          await m.createTable(customers);
          await m.createTable(zones);
          await m.createTable(restaurantTables);
          await m.createTable(paymentMethods);

          // 2. إضافة الأعمدة الجديدة لجدول الطلبات القديم بأمان
          await m.addColumn(orders, orders.customerId);
          await m.addColumn(orders, orders.tableId);
          await m.addColumn(orders, orders.orderType);
          await m.addColumn(orders, orders.paymentMethodId);

          // 3. حقن طرق الدفع الأساسية للعملاء الحاليين الذين يمتلكون النظام بالفعل
          await into(paymentMethods).insert(PaymentMethodsCompanion.insert(name: 'كاش'));
          await into(paymentMethods).insert(PaymentMethodsCompanion.insert(name: 'بطاقة إئتمان (فيزا / مدى)'));
        }

        if (from < 17) {
          await m.createTable(itemVariants);
          await m.createTable(addons);
          await m.createTable(inventoryItems);
          await m.createTable(recipes);
        }
        if (from < 18) {
          // إضافة عمود المقاس لجدول عناصر الطلب
          await m.addColumn(orderItems, orderItems.variantId);
          // إنشاء جدول تفاصيل إضافات الطلب
          await m.createTable(orderItemAddons);
        }
      },
      beforeOpen: (details) async {
        // Enable Foreign Keys for relational integrity
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

// Refactored: Extracted helper function to be used in dependency injection setup (e.g., dependency_injection.dart)
LazyDatabase openConnection(String dbName) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName)); 
    return NativeDatabase.createInBackground(file);
  });
}