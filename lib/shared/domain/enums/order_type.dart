enum OrderType { dineIn, takeaway, delivery }

extension OrderTypeExtension on OrderType {
  // للحفظ في قاعدة البيانات
  String toValue() => name;

  // للعرض في واجهة المستخدم
  String toDisplayName() {
    switch (this) {
      case OrderType.dineIn:
        return 'صالة (Dine-in)';
      case OrderType.takeaway:
        return 'تيك أواي';
      case OrderType.delivery:
        return 'توصيل';
    }
  }

  // للاسترجاع من قاعدة البيانات
  static OrderType fromValue(String value) {
    return OrderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderType.takeaway, // قيمة افتراضية آمنة
    );
  }
}