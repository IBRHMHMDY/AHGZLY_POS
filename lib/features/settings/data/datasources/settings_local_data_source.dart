import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/settings/data/models/app_settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getSettings();
  Future<void> updateSettings(AppSettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final DatabaseHelper databaseHelper;

  SettingsLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<AppSettingsModel> getSettings() async {
    final db = await databaseHelper.database;
    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    
    if (result.isNotEmpty) {
      return AppSettingsModel.fromMap(result.first);
    } else {
      throw Exception('الإعدادات غير موجودة');
    }
  }

  @override
  Future<void> updateSettings(AppSettingsModel settings) async {
    final db = await databaseHelper.database;
    await db.update(
      'settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}