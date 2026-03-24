import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/license/data/models/license_model.dart';

abstract class LicenseLocalDataSource {
  Future<LicenseModel> checkLicenseStatus();
  Future<void> activateLicense(String licenseKey);
}

class LicenseLocalDataSourceImpl implements LicenseLocalDataSource {
  final DatabaseHelper dbHelper;

  LicenseLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<LicenseModel> checkLicenseStatus() async {
    try {
      final dbPath = await getDatabasesPath();
      final hiddenFile = File(join(dbPath, '.sys_auth_config'));

      String hiddenDate = '';
      if (await hiddenFile.exists()) {
        hiddenDate = await hiddenFile.readAsString();
      }

      final db = await dbHelper.database;
      final licenseData = await db.query('license');

      bool isActivated = false;
      String dbDate = '';
      
      if (licenseData.isNotEmpty) {
        isActivated = licenseData.first['is_activated'] == 1;
        dbDate = licenseData.first['trial_start_date'] as String;
      }

      String trueStartDateStr = '';

      if (hiddenDate.isNotEmpty) {
        trueStartDateStr = hiddenDate;
        if (dbDate != hiddenDate && !isActivated) {
          if (licenseData.isEmpty) {
            await db.insert('license', {
              'id': 1,
              'is_activated': 0,
              'license_key': '',
              'trial_start_date': hiddenDate
            });
          } else {
            await db.update('license', {'trial_start_date': hiddenDate}, where: 'id = 1');
          }
        }
      } else if (dbDate.isNotEmpty) {
        trueStartDateStr = dbDate;
        await hiddenFile.writeAsString(dbDate);
      } else {
        trueStartDateStr = DateTime.now().subtract(const Duration(days: 40)).toIso8601String();
        await hiddenFile.writeAsString(trueStartDateStr);
        if (licenseData.isEmpty) {
          await db.insert('license', {
            'id': 1,
            'is_activated': 0,
            'license_key': '',
            'trial_start_date': trueStartDateStr
          });
        } else {
          await db.update('license', {'trial_start_date': trueStartDateStr}, where: 'id = 1');
        }
      }

      int elapsedDays = 0;
      bool isTrialExpired = false;

      if (!isActivated) {
        try {
          final trialStart = DateTime.parse(trueStartDateStr);
          final difference = DateTime.now().difference(trialStart);
          elapsedDays = difference.inDays;

          if (elapsedDays > 37 || elapsedDays < 0) {
            isTrialExpired = true;
          }
        } catch (e) {
          isTrialExpired = true;
        }
      }

      final updatedLicenseData = await db.query('license');
      return LicenseModel.fromJson(updatedLicenseData.first, elapsedDays, isTrialExpired);
    } catch (e) {
      throw Exception('Database Error: $e');
    }
  }

  @override
  Future<void> activateLicense(String licenseKey) async {
    try {
      final db = await dbHelper.database;
      // هنا يمكنك إضافة منطق التحقق من صحة السيريال إذا لزم الأمر
      await db.update(
        'license', 
        {
          'is_activated': 1,
          'license_key': licenseKey,
        }, 
        where: 'id = 1'
      );
    } catch (e) {
      throw Exception('Database Error: $e');
    }
  }
}