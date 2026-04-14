import 'package:ahgzly_pos/core/common/enums/enums_data.dart';
import 'package:drift/drift.dart';
import 'package:ahgzly_pos/core/extensions/order_status.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:ahgzly_pos/core/extensions/payment_method.dart';

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
  // [Refactor] استخدام OrderTypeExtension للوصول إلى دالة fromValue
  OrderType fromSql(String fromDb) => OrderTypeExtension.fromValue(fromDb);
  
  @override
  // [Refactor] استخدام دالة toValue من الـ Extension
  String toSql(OrderType value) => value.toValue();
}

// 3. محول حالة الطلب
class OrderStatusConverter extends TypeConverter<OrderStatus, String> {
  const OrderStatusConverter();
  
  @override
  // [Refactor] استخدام OrderStatusExtension للوصول إلى دالة fromValue
  OrderStatus fromSql(String fromDb) => OrderStatusExtension.fromValue(fromDb);
  
  @override
  String toSql(OrderStatus value) => value.toValue();
}

// 4. محول طريقة الدفع
class PaymentMethodConverter extends TypeConverter<PaymentMethod, String> {
  const PaymentMethodConverter();
  
  @override
  // [Refactor] استخدام PaymentMethodExtension للوصول إلى دالة fromValue
  PaymentMethod fromSql(String fromDb) => PaymentMethodExtension.fromValue(fromDb);
  
  @override
  String toSql(PaymentMethod value) => value.toValue();
}

// 5. محول خاص بحالة الوردية (ShiftStatus)
class ShiftStatusConverter extends TypeConverter<ShiftStatus, String> {
  const ShiftStatusConverter();

  @override
  ShiftStatus fromSql(String fromDb) {
    return ShiftStatus.values.firstWhere((e) => e.name == fromDb, orElse: () => ShiftStatus.closed);
  }

  @override
  String toSql(ShiftStatus value) {
    return value.name;
  }
}

