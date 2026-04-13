import 'package:intl/intl.dart';

// تم إنشاء هذا الـ Extension لضمان توحيد (DRY Principle) 
// طريقة عرض التواريخ والأوقات في كامل شاشات وتقارير النظام.
extension DateTimeExtension on DateTime {
  
  // عرض التاريخ فقط (مثال: 13-04-2026) مفيد في شاشات التقارير
  String toDisplayDate() {
    return DateFormat('dd-MM-yyyy').format(this);
  }

  // عرض الوقت فقط (مثال: 01:27 م) مفيد في شاشة تفاصيل الطلب والفواتير
  String toDisplayTime() {
    return DateFormat('hh:mm a').format(this);
  }

  // عرض التاريخ والوقت معاً (مثال: 13-04-2026 01:27 م) مفيد لطباعة الإيصالات
  String toDisplayDateTime() {
    return DateFormat('dd-MM-yyyy hh:mm a').format(this);
  }

  // دوال الحفظ في قاعدة البيانات موجودة مسبقاً في Dart عبر toIso8601String()
  // وللاسترجاع نستخدم DateTime.parse(value)
}