// مسار الملف: lib/core/database/app_database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// --- Imports ---
import 'package:ahgzly_pos/core/database/tables.dart';
import 'package:ahgzly_pos/core/database/types_converter.dart';
import 'package:ahgzly_pos/core/database/migrations/app_migrator.dart';
import 'package:ahgzly_pos/shared/domain/enums/order_status.dart';
import 'package:ahgzly_pos/shared/domain/enums/order_type.dart';

import 'package:ahgzly_pos/core/database/daos/customers_dao.dart';
import 'package:ahgzly_pos/core/database/daos/inventory_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // 🗄️ Core & Auth
    License, Settings, Users, Shifts, Categories,
    Items, Expenses, Orders, OrderItems,

    // 🧑‍🤝‍🧑 Shared (Customers & Tables)
    Customers, Zones, RestaurantTables, PaymentMethods,

    // 🍔 Menu Details
    ItemVariants, Addons, OrderItemAddons,

    // 📦 Inventory & Suppliers
    InventoryItems, Recipes, Suppliers, PurchaseInvoices,
    PurchaseInvoiceItems, InventoryTransactions,
  ],
  daos: [CustomersDao, InventoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 20;

  // 🚀 [Refactored]: تم نقل كل منطق الميغريشن إلى كلاس خارجي لسهولة القراءة والصيانة
  @override
  MigrationStrategy get migration => AppMigrator(this).strategy;
}

// 🔧 Database Connection Initialization
LazyDatabase openConnection(String dbName) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName));
    return NativeDatabase.createInBackground(file);
  });
}
