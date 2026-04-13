import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/extensions/print_mode.dart';
import 'package:ahgzly_pos/features/settings/data/models/app_settings_model.dart';
import 'package:drift/drift.dart'; 

abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getSettings();
  Future<void> updateSettings(AppSettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final AppDatabase appDatabase;

  SettingsLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<AppSettingsModel> getSettings() async {
    final result = await (appDatabase.select(appDatabase.settings)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    
    if (result != null) {
      // [Refactored]: استخدام Factory الجديد
      return AppSettingsModel.fromDrift(result);
    } else {
      throw CacheException('الإعدادات غير موجودة');
    }
  }

  @override
  Future<void> updateSettings(AppSettingsModel settings) async {
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
        // [Refactored]: استرجاع القيمة النصية لحفظها في Drift
        printMode: Value(settings.printMode.toValue()), 
      ),
    );
  }
}