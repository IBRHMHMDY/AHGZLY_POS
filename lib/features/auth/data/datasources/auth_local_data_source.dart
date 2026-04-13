import 'package:ahgzly_pos/core/common/users/models/user_model.dart';
import 'package:ahgzly_pos/core/database/drift/app_database.dart'; 
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

  // تم التصحيح: استخدام UserDrift المُولد من Drift لتجنب أي تعارض
  Map<String, dynamic> _driftUserToMap(UserDrift driftUser) {
    return {
      'id': driftUser.id,
      'name': driftUser.name,
      'pin_hash': driftUser.pinHash,
      'salt': driftUser.salt,
      'role': driftUser.role,
      'is_active': driftUser.isActive ? 1 : 0,
      'failed_attempts': driftUser.failedAttempts,
      'lockout_until': driftUser.lockoutUntil,
    };
  }

  @override
  Future<UserModel> loginWithPin(String pin) async {
    final lockoutUntilStr = await secureStorage.read(key: 'device_lockout_until');
    if (lockoutUntilStr != null) {
      final lockoutUntil = DateTime.tryParse(lockoutUntilStr);
      if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
        final remainingMins = lockoutUntil.difference(DateTime.now()).inMinutes;
        throw AuthException('تم حظر الجهاز مؤقتاً لحمايتك. يرجى المحاولة بعد $remainingMins دقيقة.');
      } else {
        await secureStorage.delete(key: 'device_lockout_until');
        await secureStorage.write(key: 'device_failed_attempts', value: '0');
      }
    }

    // الاستعلام سيعيد قائمة من UserDrift بفضل الـ DataClassName
    final users = await (appDatabase.select(appDatabase.users)
          ..where((t) => t.isActive.equals(true)))
        .get();

    for (var driftUser in users) {
      final salt = driftUser.salt;
      final pinHash = driftUser.pinHash;

      if (HashUtil.verifyPin(pin, salt, pinHash)) {
        await secureStorage.write(key: 'device_failed_attempts', value: '0');
        // إرسال كائن Drift بأمان إلى الـ Mapper
        return UserModel.fromMap(_driftUserToMap(driftUser)); 
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