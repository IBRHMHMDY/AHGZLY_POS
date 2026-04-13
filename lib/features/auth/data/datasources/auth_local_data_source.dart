import 'package:ahgzly_pos/core/common/users/models/user_model.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart'; 
import 'package:ahgzly_pos/core/utils/hash_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> loginWithPin(String pin);
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase appDatabase; 
  final FlutterSecureStorage secureStorage;

  static const int maxFailedAttempts = 3;
  static const int lockoutMinutes = 5;

  AuthLocalDataSourceImpl({required this.appDatabase, required this.secureStorage});

  @override
  Future<UserModel> loginWithPin(String pin) async {
    String? lockoutUntilStr = await secureStorage.read(key: 'device_lockout_until');
    if (lockoutUntilStr != null) {
      final lockoutTime = DateTime.tryParse(lockoutUntilStr);
      if (lockoutTime != null && DateTime.now().isBefore(lockoutTime)) {
        final remaining = lockoutTime.difference(DateTime.now()).inMinutes;
        throw AuthException('التطبيق محظور مؤقتاً. حاول مجدداً بعد $remaining دقائق.');
      } else {
        await secureStorage.delete(key: 'device_lockout_until');
        await secureStorage.write(key: 'device_failed_attempts', value: '0');
      }
    }

    final users = await (appDatabase.select(appDatabase.users)
          ..where((t) => t.isActive.equals(true)))
        .get();

    for (var driftUser in users) {
      final salt = driftUser.salt;
      final pinHash = driftUser.pinHash;

      if (HashUtil.verifyPin(pin, salt, pinHash)) {
        await secureStorage.write(key: 'device_failed_attempts', value: '0');
        // [Refactored]: قراءة آمنة ومباشرة من كائن Drift بدون وسيط
        return UserModel.fromDrift(driftUser); 
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
      throw AuthException('الرمز السري غير صحيح. المحاولات المتبقية: ${maxFailedAttempts - failedAttempts}');
    }
  }

  @override
  Future<void> logout() async {
    // ضع هنا منطق تسجيل الخروج إن وجد
  }
}