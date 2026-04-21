enum PrintMode { ask, customer, kitchen, both }

extension PrintModeExtension on PrintMode {
  String toValue() => name;

  String toDisplayName() {
    switch (this) {
      case PrintMode.ask:
        return 'اسأل أولاً (عرض نافذة الطباعة)';
      case PrintMode.customer:
        return 'طباعة فاتورة العميل تلقائياً';
      case PrintMode.kitchen:
        return 'طباعة بون المطبخ تلقائياً';
      case PrintMode.both:
        return 'طباعة العميل والمطبخ تلقائياً';
    }
  }

  static PrintMode fromValue(String val) {
    return PrintMode.values.firstWhere(
      (e) => e.name == val,
      orElse: () => PrintMode.ask,
    );
  }
}