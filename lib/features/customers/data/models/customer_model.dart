import 'package:ahgzly_pos/core/database/app_database.dart';

class CustomerModel {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    required this.createdAt,
  });

  factory CustomerModel.fromDrift(CustomerData data) {
    return CustomerModel(
      id: data.id,
      name: data.name,
      phone: data.phone,
      address: data.address,
      createdAt: data.createdAt,
    );
  }
}

class CustomerOrderSummary {
  final int id;
  final int total;
  final int itemsCount;
  final String orderType;
  final DateTime createdAt;

  CustomerOrderSummary({
    required this.id,
    required this.total,
    required this.itemsCount,
    required this.orderType,
    required this.createdAt,
  });
}

class CustomerDetailModel {
  final CustomerModel customer;
  final int totalSpent;
  final int totalOrders;
  final int avgOrderValue;
  final List<CustomerOrderSummary> recentOrders;

  CustomerDetailModel({
    required this.customer,
    required this.totalSpent,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.recentOrders,
  });
}
