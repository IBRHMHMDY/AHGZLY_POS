import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';

extension OrderStatusExtension on OrderStatus {
  // تُستخدم لحفظ القيمة في قاعدة البيانات بشكل آمن (بدلاً من حفظ الـ index الذي قد يتغير)
  String toValue() => name;

  // تُستخدم في واجهة المستخدم (UI) لعرض نصوص واضحة ومقروءة للمستخدم
  String toDisplayName() {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.refunded:
        return 'مرتجع';
    }
  }

  // دالة مساعدة لتحويل النص القادم من قاعدة البيانات إلى Enum بأمان
  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending, // قيمة افتراضية آمنة (Fallback) لمنع الـ Null Errors
    );
  }
}