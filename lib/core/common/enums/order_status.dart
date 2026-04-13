enum OrderStatus {
  pending('في الانتظار'),
  completed('مكتمل'),
  cancelled('تم الإلغاء'),
  refunded('مرتجع');

  final String arabicName;
  const OrderStatus(this.arabicName);

  static OrderStatus fromString(String name) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => OrderStatus.completed, 
    );
  }
}