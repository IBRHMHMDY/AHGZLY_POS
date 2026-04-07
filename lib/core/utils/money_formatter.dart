class MoneyFormatter {
  /// تحويل المبلغ من قروش (int) إلى نص صالح للعرض للمستخدم (مثال: 1550 -> "15.50")
  static String format(int amountInCents) {
    return (amountInCents / 100).toStringAsFixed(2);
  }

  /// تحويل المبلغ من قروش إلى كسر عشري (يُستخدم للعمليات الحسابية المؤقتة إن لزم الأمر)
  static double toDouble(int amountInCents) {
    return amountInCents / 100.0;
  }

  /// تحويل المدخلات (double) إلى قروش (int) لتخزينها في قاعدة البيانات بأمان
  static int toCents(double amount) {
    // نستخدم round() لتجنب أي كسور متبقية من الفاصلة العائمة
    return (amount * 100).round();
  }
}