import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.taxRate,
    required super.serviceRate,
    required super.deliveryFee,
    required super.printerName,
    required super.restaurantName,
    required super.taxNumber,
    required super.printMode,
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      taxRate: (map['tax_rate'] as num).toDouble(),
      serviceRate: (map['service_rate'] as num).toDouble(),
      deliveryFee: (map['delivery_fee'] as num).toDouble(),
      printerName: map['printer_name'] as String,
      restaurantName: map['restaurant_name'] as String? ?? 'مـطـعـم احـجـزلـي',
      taxNumber: map['tax_number'] as String? ?? '123-456-789',
      printMode: map['print_mode'] as String? ?? 'ask',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'tax_rate': taxRate,
      'service_rate': serviceRate,
      'delivery_fee': deliveryFee,
      'printer_name': printerName,
      'restaurant_name': restaurantName,
      'tax_number': taxNumber,
      'print_mode': printMode,
    };
  }

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      taxRate: entity.taxRate,
      serviceRate: entity.serviceRate,
      deliveryFee: entity.deliveryFee,
      printerName: entity.printerName,
      restaurantName: entity.restaurantName,
      taxNumber: entity.taxNumber,
      printMode: entity.printMode,
    );
  }
}