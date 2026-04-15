import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  // للواجهة والتقارير
  String toDisplayDate() => DateFormat('dd-MM-yyyy').format(this);
  String toDisplayTime() => DateFormat('hh:mm a').format(this);
  String toDisplayDateTime() => DateFormat('dd-MM-yyyy hh:mm a').format(this);

  // 🪄 [Refactored]: دوال محاسبية هامة لجلب الورديات بدقة ومنع تداخل أيام العمل
  DateTime get startOfDay => DateTime(year, month, day, 0, 0, 0);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}