import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/utils/enums/enums_data.dart'; // تأكد من وجود مسار الـ Enum
import 'package:ahgzly_pos/core/utils/extensions/print_mode.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';

class AppSettingsModel extends AppSettingsEntity {
  const AppSettingsModel({
    required super.taxRate,
    required super.serviceRate,
    required super.deliveryFee,
    required super.printerName,
    required super.restaurantName,
    required super.taxNumber,
    required super.printMode,
  });

  // 🪄 [Refactored]: إضافة fromJson وتأمينه كلياً ضد الـ null لحل شاشة الموت الحمراء (Crash Fix)
  factory AppSettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      // إرجاع قيم افتراضية آمنة ومطابقة لمحركنا المحاسبي في حال كان الـ Cache فارغاً
      return const AppSettingsModel(
        taxRate: 0.15, // 15% افتراضي
        serviceRate: 0.0,
        deliveryFee: 0,
        printerName: '',
        restaurantName: 'اسم المطعم',
        taxNumber: '',
        printMode: PrintMode.ask,
      );
    }
    
    return AppSettingsModel(
      // استخدام num? للتعامل بأمان مع القيم سواء كانت int أو double من الـ JSON
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.15,
      serviceRate: (json['serviceRate'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: json['deliveryFee'] as int? ?? 0,
      printerName: json['printerName'] as String? ?? '',
      restaurantName: json['restaurantName'] as String? ?? 'اسم المطعم',
      taxNumber: json['taxNumber'] as String? ?? '',
      printMode: PrintModeExtension.fromValue(json['printMode'] as String? ?? 'ask'),
    );
  }

  // 🪄 [Refactored]: دالة toJson لضمان حفظ البيانات بشكل صحيح في الـ Cache
  Map<String, dynamic> toJson() {
    return {
      'taxRate': taxRate,
      'serviceRate': serviceRate,
      'deliveryFee': deliveryFee,
      'printerName': printerName,
      'restaurantName': restaurantName,
      'taxNumber': taxNumber,
      'printMode': printMode.toValue(),
    };
  }

  // [Refactored]: قراءة آمنة ومباشرة من Drift
  factory AppSettingsModel.fromDrift(SettingsData data) {
    return AppSettingsModel(
      taxRate: data.taxRate,
      serviceRate: data.serviceRate,
      deliveryFee: data.deliveryFee,
      printerName: data.printerName,
      restaurantName: data.restaurantName,
      taxNumber: data.taxNumber,
      printMode: PrintModeExtension.fromValue(data.printMode), 
    );
  }

  factory AppSettingsModel.fromEntity(AppSettingsEntity setting) {
    return AppSettingsModel(
      taxRate: setting.taxRate,
      serviceRate: setting.serviceRate,
      deliveryFee: setting.deliveryFee,
      printerName: setting.printerName,
      restaurantName: setting.restaurantName,
      taxNumber: setting.taxNumber,
      printMode: setting.printMode,
    );
  }
}