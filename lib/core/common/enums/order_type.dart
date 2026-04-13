enum OrderType {
  dineIn('صالة'),
  takeaway('تيك أواي'),
  delivery('دليفري');

  final String arabicName;
  const OrderType(this.arabicName);

  // [Clean Code Helper] دالة لتحويل النص القادم من الداتا بيز إلى Enum بشكل آمن
  static OrderType fromString(String name) {
    return OrderType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => OrderType.takeaway, // قيمة افتراضية آمنة
    );
  }
}