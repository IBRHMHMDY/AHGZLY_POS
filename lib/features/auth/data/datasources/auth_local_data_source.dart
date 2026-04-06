import 'package:ahgzly_pos/core/common/models/user_model.dart';
import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart'; 
import 'package:ahgzly_pos/core/utils/hash_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> loginWithPin(String pin);
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper databaseHelper;
  final FlutterSecureStorage secureStorage;

  static const int maxFailedAttempts = 3;
  static const int lockoutMinutes = 5;

  AuthLocalDataSourceImpl({required this.databaseHelper, required this.secureStorage});

  @override
  Future<UserModel> loginWithPin(String pin) async {
    final lockoutUntilStr = await secureStorage.read(key: 'device_lockout_until');
    if (lockoutUntilStr != null) {
      final lockoutUntil = DateTime.tryParse(lockoutUntilStr);
      if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
        final remainingMins = lockoutUntil.difference(DateTime.now()).inMinutes;
        throw AuthException('تم حظر الجهاز مؤقتاً لحمايتك. يرجى المحاولة بعد $remainingMins دقيقة.');
      } else {
        // Lockout expired, clear it
        await secureStorage.delete(key: 'device_lockout_until');
        await secureStorage.write(key: 'device_failed_attempts', value: '0');
      }
    }

    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> users = await db.query('users', where: 'is_active = 1');

    for (var userMap in users) {
      final salt = userMap['salt'] as String?;
      final pinHash = userMap['pin_hash'] as String?;

      if (salt != null && pinHash != null) {
        if (HashUtil.verifyPin(pin, salt, pinHash)) {
          // Success: Reset failed attempts
          await secureStorage.write(key: 'device_failed_attempts', value: '0');
          return UserModel.fromMap(userMap); 
        }
      }
    }

   
    String? attemptsStr = await secureStorage.read(key: 'device_failed_attempts');
    int failedAttempts = int.tryParse(attemptsStr ?? '0') ?? 0;
    failedAttempts++;

    if (failedAttempts >= maxFailedAttempts) {
      final lockoutTime = DateTime.now().add(const Duration(minutes: lockoutMinutes));
      await secureStorage.write(key: 'device_lockout_until', value: lockoutTime.toIso8601String());
      throw AuthException('تجاوزت الحد الأقصى للمحاولات. تم حظر الدخول لمدة $lockoutMinutes دقائق.');
    } else {
      await secureStorage.write(key: 'device_failed_attempts', value: failedAttempts.toString());
      final remaining = maxFailedAttempts - failedAttempts;
      throw AuthException('الرقم السري غير صحيح. متبقي لك $remaining محاولات.');
    }
  }

  @override
  Future<void> logout() async {
    // Session clearing logic if any
  }
}