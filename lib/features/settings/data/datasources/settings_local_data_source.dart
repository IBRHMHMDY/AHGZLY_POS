import 'package:ahgzly_pos/core/common/enums/enums_data.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; 
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
      return AppSettingsModel.fromDrift(result);
    } else {
      // 🪄 [Refactored]: بدلاً من رمي خطأ، نقوم بإنشاء إعدادات افتراضية آمنة للصف الأول
      final defaultSettings = const AppSettingsModel(
        taxRate: 0.15, // 15% افتراضي
        serviceRate: 0.0,
        deliveryFee: 0,
        printerName: '',
        restaurantName: 'اسم المطعم',
        taxNumber: '',
        printMode: PrintMode.ask,
      );
      await updateSettings(defaultSettings);
      return defaultSettings;
    }
  }

  @override
  Future<void> updateSettings(AppSettingsModel settings) async {
    // 🪄 [Refactored]: استخدام insertOnConflictUpdate يضمن الإنشاء أو التحديث بأمان للصف رقم 1
    await appDatabase.into(appDatabase.settings).insertOnConflictUpdate(
      SettingsCompanion(
        id: const Value(1), // إجبار التعامل مع الصف الأول دائماً
        taxRate: Value(settings.taxRate),
        serviceRate: Value(settings.serviceRate),
        deliveryFee: Value(settings.deliveryFee),
        printerName: Value(settings.printerName),
        restaurantName: Value(settings.restaurantName),
        taxNumber: Value(settings.taxNumber),
        printMode: Value(settings.printMode.toValue()), 
      ),
    );
  }
}