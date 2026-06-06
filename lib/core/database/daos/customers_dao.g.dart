// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomersDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $ZonesTable get zones => attachedDatabase.zones;
  $RestaurantTablesTable get restaurantTables =>
      attachedDatabase.restaurantTables;
  $PaymentMethodsTable get paymentMethods => attachedDatabase.paymentMethods;
  CustomersDaoManager get managers => CustomersDaoManager(this);
}

class CustomersDaoManager {
  final _$CustomersDaoMixin _db;
  CustomersDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$ZonesTableTableManager get zones =>
      $$ZonesTableTableManager(_db.attachedDatabase, _db.zones);
  $$RestaurantTablesTableTableManager get restaurantTables =>
      $$RestaurantTablesTableTableManager(
        _db.attachedDatabase,
        _db.restaurantTables,
      );
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(
        _db.attachedDatabase,
        _db.paymentMethods,
      );
}
