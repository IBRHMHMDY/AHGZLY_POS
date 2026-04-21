import 'dart:io';
import 'package:ahgzly_pos/core/common/enums/enums_data.dart';
import 'package:ahgzly_pos/core/database/types_converter.dart';
import 'package:ahgzly_pos/core/utils/hash_util.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart'; 

@DriftDatabase(tables: [
  License, Settings, Users, Shifts, Categories, 
  Items, Expenses, Orders, OrderItems,
])
class AppDatabase extends _$AppDatabase {
  
  // Refactored: Accept QueryExecutor to allow dependency injection (e.g., In-Memory DB for testing)
  AppDatabase(super.e);

  @override
  int get schemaVersion => 15; 

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
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 15) {
          // إضافة الأعمدة الجديدة للجداول القديمة بدون مسح بيانات العميل
          await m.addColumn(items, items.costPrice);
          await m.addColumn(orders, orders.totalCost);
          await m.addColumn(orderItems, orderItems.unitCostPrice);
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