import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:drift/drift.dart';
import 'package:ahgzly_pos/core/utils/extensions/order_status.dart';
import 'package:ahgzly_pos/core/utils/extensions/order_type.dart';
import 'package:ahgzly_pos/core/utils/extensions/payment_method.dart';

// ==========================================
// 🔄 Type Converters (Clean Code Approach)
// ==========================================

// 1. محول التواريخ (Standard ISO 8601 with UTC Enforcement)
class DateTimeConverter extends TypeConverter<DateTime, String> {
  const DateTimeConverter();
  
  @override
  // [Refactored]: قراءة التاريخ وتحويله للتوقيت المحلي للجهاز لعرضه في الواجهة
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toLocal();
  
  @override
  // [Refactored]: حفظ التواريخ دائماً بصيغة التوقيت العالمي (UTC) لضمان الدقة وتجنب مشاكل المناطق الزمنية
  String toSql(DateTime value) => value.toUtc().toIso8601String();
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

// 4. محول طريقة الدفع
class PaymentMethodConverter extends TypeConverter<PaymentMethod, String> {
  const PaymentMethodConverter();
  
  @override
  PaymentMethod fromSql(String fromDb) => PaymentMethodExtension.fromValue(fromDb);
  
  @override
  String toSql(PaymentMethod value) => value.toValue();
}

// 5. محول حالة الوردية
class ShiftStatusConverter extends TypeConverter<ShiftStatus, String> {
  const ShiftStatusConverter();
  
  @override
  ShiftStatus fromSql(String fromDb) {
    return ShiftStatus.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
      orElse: () => ShiftStatus.closed,
    );
  }
  
  @override
  String toSql(ShiftStatus value) => value.toString().split('.').last;
}