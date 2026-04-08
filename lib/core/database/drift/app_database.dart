// مسار الملف: lib/core/database/drift/app_database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart'; // هذا الملف سيتم توليده تلقائياً

@DriftDatabase(tables: [
  LicenseTable,
  SettingsTable,
  UsersTable,
  ShiftsTable,
  CategoriesTable,
  ItemsTable,
  ExpensesTable,
  OrdersTable,
  OrderItemsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 14; // نفس رقم الإصدار القديم لضمان التوافق

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // إدخال البيانات الافتراضية للترخيص والإعدادات بعد إنشاء الجداول
        await into(licenseTable).insert(
          LicenseTableCompanion.insert(
            isActivated: const Value(false),
            trialStartDate: Value(DateTime.now().toIso8601String()),
          ),
        );

        await into(settingsTable).insert(
          SettingsTableCompanion.insert(
            taxRate: 0.14,
            serviceRate: 0.12,
            deliveryFee: 2000,
            printerName: 'EPSON Printer',
            restaurantName: 'مـطـعـم احـجـزلـي',
            taxNumber: '123-456-789',
            printMode: 'ask',
          ),
        );
      },
      beforeOpen: (details) async {
        // تفعيل Foreign Keys لضمان تكامل العلاقات
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos_sys_drift.db')); // اسم جديد مبدئياً لتجنب التعارض أثناء التطوير
    return NativeDatabase.createInBackground(file);
  });
}