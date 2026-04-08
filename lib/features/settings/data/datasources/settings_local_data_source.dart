// مسار الملف: lib/features/settings/data/datasources/settings_local_data_source.dart

import 'package:ahgzly_pos/core/database/drift/app_database.dart'; // استيراد Drift
import 'package:ahgzly_pos/features/settings/data/models/app_settings_model.dart';
import 'package:drift/drift.dart'; // استيراد Value

abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getSettings();
  Future<void> updateSettings(AppSettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final AppDatabase appDatabase; // Refactored: استخدام AppDatabase

  SettingsLocalDataSourceImpl({required this.appDatabase});

  // Mapper لتحويل كائن Drift إلى Map تتوقعه Models
  Map<String, dynamic> _driftSettingsToMap(SettingsDrift driftSettings) {
    return {
      'id': driftSettings.id,
      'tax_rate': driftSettings.taxRate,
      'service_rate': driftSettings.serviceRate,
      'delivery_fee': driftSettings.deliveryFee,
      'printer_name': driftSettings.printerName,
      'restaurant_name': driftSettings.restaurantName,
      'tax_number': driftSettings.taxNumber,
      'print_mode': driftSettings.printMode,
    };
  }

  @override
  Future<AppSettingsModel> getSettings() async {
    // Refactored: استعلام Drift الآمن لجلب الإعدادات (id = 1)
    final result = await (appDatabase.select(appDatabase.settings)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    
    if (result != null) {
      return AppSettingsModel.fromMap(_driftSettingsToMap(result));
    } else {
      throw Exception('الإعدادات غير موجودة');
    }
  }

  @override
  Future<void> updateSettings(AppSettingsModel settings) async {
    // Refactored: تحديث الإعدادات باستخدام Companions
    await (appDatabase.update(appDatabase.settings)
          ..where((t) => t.id.equals(1)))
        .write(
      SettingsCompanion(
        taxRate: Value(settings.taxRate),
        serviceRate: Value(settings.serviceRate),
        deliveryFee: Value(settings.deliveryFee),
        printerName: Value(settings.printerName),
        restaurantName: Value(settings.restaurantName),
        taxNumber: Value(settings.taxNumber),
        printMode: Value(settings.printMode),
      ),
    );
  }
}