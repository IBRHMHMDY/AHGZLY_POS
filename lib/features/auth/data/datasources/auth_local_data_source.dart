import 'package:ahgzly_pos/core/common/users/models/user_model.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart'; 
import 'package:ahgzly_pos/core/utils/hash_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> loginWithPin(String pin);
  Future<void> logout();
}

// 🛡️ تجميع الثوابت لمنع الأخطاء الإملائية
class _AuthKeys {
  static const String lockoutUntil = 'device_lockout_until';
  static const String failedAttempts = 'device_failed_attempts';
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase appDatabase; 
  final FlutterSecureStorage secureStorage;

  static const int maxFailedAttempts = 3;
  static const int lockoutMinutes = 5;

  AuthLocalDataSourceImpl({required this.appDatabase, required this.secureStorage});

  @override
  Future<UserModel> loginWithPin(String pin) async {
    String? lockoutUntilStr = await secureStorage.read(key: _AuthKeys.lockoutUntil);
    if (lockoutUntilStr != null) {
      final lockoutTime = DateTime.tryParse(lockoutUntilStr);
      if (lockoutTime != null && DateTime.now().isBefore(lockoutTime)) {
        final remaining = lockoutTime.difference(DateTime.now()).inMinutes;
        throw AuthException('التطبيق محظور مؤقتاً. حاول مجدداً بعد $remaining دقائق.');
      } else {
        await secureStorage.delete(key: _AuthKeys.lockoutUntil);
        await secureStorage.write(key: _AuthKeys.failedAttempts, value: '0');
      }
    }

    final users = await (appDatabase.select(appDatabase.users)
          ..where((t) => t.isActive.equals(true)))
        .get();

    for (var driftUser in users) {
      if (HashUtil.verifyPin(pin, driftUser.salt, driftUser.pinHash)) {
        await secureStorage.write(key: _AuthKeys.failedAttempts, value: '0');
        return UserModel.fromDrift(driftUser); 
      }
    }

    String? attemptsStr = await secureStorage.read(key: _AuthKeys.failedAttempts);
    int failedAttempts = int.tryParse(attemptsStr ?? '0') ?? 0;
    failedAttempts++;

    if (failedAttempts >= maxFailedAttempts) {
      final lockoutTime = DateTime.now().add(const Duration(minutes: lockoutMinutes));
      await secureStorage.write(key: _AuthKeys.lockoutUntil, value: lockoutTime.toIso8601String());
      throw AuthException('تجاوزت الحد الأقصى للمحاولات. تم حظر الدخول لمدة $lockoutMinutes دقائق.');
    } else {
      await secureStorage.write(key: _AuthKeys.failedAttempts, value: failedAttempts.toString());
      throw AuthException('الرمز السري غير صحيح. المحاولات المتبقية: ${maxFailedAttempts - failedAttempts}');
    }
  }

  @override
  Future<void> logout() async {}
}