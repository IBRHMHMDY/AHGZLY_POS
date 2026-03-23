import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.taxRate,
    required super.serviceRate,
    required super.deliveryFee,
    required super.printerName,
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      taxRate: (map['tax_rate'] as num).toDouble(),
      serviceRate: (map['service_rate'] as num).toDouble(),
      deliveryFee: (map['delivery_fee'] as num).toDouble(),
      printerName: map['printer_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1, // دائماً 1 لأننا نملك صف إعدادات واحد فقط
      'tax_rate': taxRate,
      'service_rate': serviceRate,
      'delivery_fee': deliveryFee,
      'printer_name': printerName,
    };
  }

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      taxRate: entity.taxRate,
      serviceRate: entity.serviceRate,
      deliveryFee: entity.deliveryFee,
      printerName: entity.printerName,
    );
  }
}