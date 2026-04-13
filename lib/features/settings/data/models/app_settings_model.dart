import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/extensions/print_mode.dart';
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

  // [Refactored]: قراءة آمنة ومباشرة من Drift
  factory AppSettingsModel.fromDrift(SettingsData data) {
    return AppSettingsModel(
      taxRate: data.taxRate,
      serviceRate: data.serviceRate,
      deliveryFee: data.deliveryFee,
      printerName: data.printerName,
      restaurantName: data.restaurantName,
      taxNumber: data.taxNumber,
      // تحويل النص المحفوظ في الداتا بيز إلى Enum
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