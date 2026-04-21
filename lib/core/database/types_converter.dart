import 'package:drift/drift.dart';
import 'package:ahgzly_pos/core/extensions/order_status.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';

// ==========================================
// 🔄 Type Converters (Clean Code Approach)
// ==========================================

// 1. محول التواريخ (Standard ISO 8601)
class DateTimeConverter extends TypeConverter<DateTime, String> {
  const DateTimeConverter();
  
  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb);
  
  @override
  String toSql(DateTime value) => value.toIso8601String();
}

// 2. محول نوع الطلب
class OrderTypeConverter extends TypeConverter<OrderType, String> {
  const OrderTypeConverter();
  
  @override
  OrderType fromSql(String fromDb) => OrderTypeExtension.fromValue(fromDb);
  
  @override
  String toSql(OrderType value) => value.toValue();
}

// 3. محول حالة الطلب
class OrderStatusConverter extends TypeConverter<OrderStatus, String> {
  const OrderStatusConverter();
  
  @override
  OrderStatus fromSql(String fromDb) => OrderStatusExtension.fromValue(fromDb);
  
  @override
  String toSql(OrderStatus value) => value.toValue();
}