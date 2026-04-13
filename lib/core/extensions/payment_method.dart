

import 'package:ahgzly_pos/core/common/enums/enums_data.dart';

extension PaymentMethodExtension on PaymentMethod {
  // للحفظ في قاعدة البيانات
  String toValue() => name;

  // للعرض في واجهة المستخدم
  String toDisplayName() {
    switch (this) {
      case PaymentMethod.cash:
        return 'كاش';
      case PaymentMethod.visa:
        return 'فيزا';
      case PaymentMethod.wallet:
        return 'محفظة إلكترونية';
      case PaymentMethod.unpaid:
        return 'آجل / غير مدفوع';
    }
  }

  // للاسترجاع من قاعدة البيانات
  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash, // قيمة افتراضية آمنة
    );
  }
}