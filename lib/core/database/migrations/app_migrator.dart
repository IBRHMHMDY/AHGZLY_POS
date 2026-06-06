// مسار الملف: lib/core/database/migrations/app_migrator.dart

import 'package:drift/drift.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/utils/hash_util.dart';

class AppMigrator {
  final AppDatabase db;

  AppMigrator(this.db);

  MigrationStrategy get strategy => MigrationStrategy(
        onCreate: (Migrator m) async {
          // 1. إنشاء كل الجداول
          await m.createAll();

          // 2. حقن البيانات الأولية الافتراضية
          await db.into(db.license).insert(
                LicenseCompanion.insert(
                  isActivated: const Value(false),
                  trialStartDate: Value(DateTime.now()),
                ),
              );

          await db.into(db.settings).insert(
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

          // إعداد مستخدمين افتراضيين
          final adminSalt = HashUtil.generateSalt();
          final adminHashedPin = HashUtil.generatePinHash('123456', adminSalt);
          final cashierSalt = HashUtil.generateSalt();
          final cashierHashedPin = HashUtil.generatePinHash('000000', cashierSalt);

          await db.into(db.users).insert(
                UsersCompanion.insert(
                  name: 'مدير النظام',
                  pinHash: adminHashedPin,
                  salt: adminSalt,
                  role: 'admin',
                  isActive: const Value(true),
                ),
              );

          await db.into(db.users).insert(
                UsersCompanion.insert(
                  name: 'كاشير 1',
                  pinHash: cashierHashedPin,
                  salt: cashierSalt,
                  role: 'cashier',
                  isActive: const Value(true),
                ),
              );

          await db.into(db.paymentMethods).insert(PaymentMethodsCompanion.insert(name: 'كاش'));
          await db.into(db.paymentMethods).insert(PaymentMethodsCompanion.insert(name: 'بطاقة إئتمان (فيزا / مدى)'));
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 15) {
            await m.addColumn(db.items, db.items.costPrice);
            await m.addColumn(db.orders, db.orders.totalCost);
            await m.addColumn(db.orderItems, db.orderItems.unitCostPrice);
          }

          if (from < 16) {
            await m.createTable(db.customers);
            await m.createTable(db.zones);
            await m.createTable(db.restaurantTables);
            await m.createTable(db.paymentMethods);

            await m.addColumn(db.orders, db.orders.customerId);
            await m.addColumn(db.orders, db.orders.tableId);
            await m.addColumn(db.orders, db.orders.orderType);
            await m.addColumn(db.orders, db.orders.paymentMethodId);

            await db.into(db.paymentMethods).insert(PaymentMethodsCompanion.insert(name: 'كاش'));
            await db.into(db.paymentMethods).insert(PaymentMethodsCompanion.insert(name: 'بطاقة إئتمان (فيزا / مدى)'));
          }

          if (from < 17) {
            await m.createTable(db.itemVariants);
            await m.createTable(db.addons);
            await m.createTable(db.inventoryItems);
            await m.createTable(db.recipes);
          }
          if (from < 18) {
            await m.addColumn(db.orderItems, db.orderItems.variantId);
            await m.createTable(db.orderItemAddons);
          }
          if (from < 20) {
            await m.createTable(db.suppliers);
            await m.createTable(db.purchaseInvoices);
            await m.createTable(db.purchaseInvoiceItems);
            await m.createTable(db.inventoryTransactions);
            await m.addColumn(db.recipes, db.recipes.addonId);
          }
        },
        beforeOpen: (details) async {
          // تفعيل المفاتيح الأجنبية للحفاظ على ترابط البيانات
          await db.customStatement('PRAGMA foreign_keys = ON');
        },
      );
}