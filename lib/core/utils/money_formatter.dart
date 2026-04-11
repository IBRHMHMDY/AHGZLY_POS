// lib/core/utils/money_formatter.dart

extension MoneyFormatterExtension on int {
  /// تحويل المبلغ من قروش (int) إلى نص صالح للعرض مع خيار إضافة العملة
  /// مثال: 1550.toFormattedMoney() -> "15.50"
  /// مثال: 1550.toFormattedMoney(currency: 'ج.م') -> "15.50 ج.م"
  String toFormattedMoney({String? currency}) {
    final formattedAmount = (this / 100).toStringAsFixed(2);
    if (currency != null && currency.isNotEmpty) {
      return '$formattedAmount $currency';
    }
    return formattedAmount;
  }

  /// تحويل المبلغ من قروش إلى كسر عشري (يُستخدم للعمليات الحسابية المؤقتة فقط)
  double toDoubleMoney() {
    return this / 100.0;
  }
}

extension DoubleToMoneyExtension on double {
  /// تحويل المدخلات (double) إلى قروش (int) لتخزينها في قاعدة البيانات بأمان
  /// نستخدم round() لتجنب أي كسور متبقية من الفاصلة العائمة
  int toCents() {
    return (this * 100).round();
  }
}

// تم الإبقاء على الكلاس القديم مع وضع علامة Deprecated لتجنب كسر الكود القديم 
// حتى نقوم بتحديثه بالكامل في باقي الملفات (Safety Rule)
@Deprecated('Use MoneyFormatterExtension on int or double directly')
class MoneyFormatter {
  static String format(int amountInCents) => amountInCents.toFormattedMoney();
  static double toDouble(int amountInCents) => amountInCents.toDoubleMoney();
  static int toCents(double amount) => amount.toCents();
}