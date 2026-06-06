// مسار الملف: lib/core/database/daos/customers_dao.dart

import 'package:drift/drift.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/database/tables.dart';

part 'customers_dao.g.dart'; // سيتم توليده بواسطة build_runner

@DriftAccessor(tables: [Customers, Zones, RestaurantTables, PaymentMethods])
class CustomersDao extends DatabaseAccessor<AppDatabase> with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Future<List<CustomerData>> getAllCustomers() => select(customers).get();
  
  Future<List<ZoneData>> getAllZones() => select(zones).get();
  
  Future<List<RestaurantTableData>> getTablesByZoneId(int zoneId) =>
      (select(restaurantTables)..where((t) => t.zoneId.equals(zoneId))).get();
      
  Future<List<PaymentMethodData>> getAllPaymentMethods() => select(paymentMethods).get();
  
  Future<int> insertCustomer(CustomersCompanion customer) => into(customers).insert(customer);
}