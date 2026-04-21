import 'package:ahgzly_pos/core/database/app_database.dart';

// ==========================================
// 🚀 Shared Database Queries Extension
// ==========================================
extension SharedQueriesExtension on AppDatabase {
  
  Future<List<CustomerData>> getAllCustomers() async {
    return await select(customers).get();
  }

  Future<List<ZoneData>> getAllZones() async {
    return await select(zones).get();
  }

  Future<List<RestaurantTableData>> getTablesByZoneId(int zoneId) async {
    return await (select(restaurantTables)..where((t) => t.zoneId.equals(zoneId))).get();
  }

  Future<List<PaymentMethodData>> getAllPaymentMethods() async {
    return await select(paymentMethods).get();
  }

  Future<int> insertCustomer(CustomersCompanion customer) async {
    return await into(customers).insert(customer);
  }
  
}