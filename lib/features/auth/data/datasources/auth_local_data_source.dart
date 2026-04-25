import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/common/users/models/user_model.dart';
import 'package:ahgzly_pos/core/utils/hash_util.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String pin);
  Future<void> logout();
  Future<UserModel?> getCachedSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase appDatabase;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.appDatabase, required this.secureStorage});

  @override
  Future<UserModel> login(String pin) async {
    // جلب جميع المستخدمين (عملية خفيفة في الـ POS لأن عدد المستخدمين قليل)
    final users = await appDatabase.select(appDatabase.users).get();
    
    for (var user in users) {
      if (!user.isActive) continue; // تخطي المستخدمين الموقوفين
      
      final hashedInput = HashUtil.generatePinHash(pin, user.salt);
      if (hashedInput == user.pinHash) {
        final userModel = UserModel.fromDrift(user);
        await _cacheSession(userModel);
        return userModel;
      }
    }
    // رمي Exception مخصص في حال فشل تسجيل الدخول
    throw AuthException('رمز الدخول غير صحيح أو الحساب موقوف');
  }

  Future<void> _cacheSession(UserModel user) async {
    await secureStorage.write(key: 'cached_user_id', value: user.id.toString());
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'cached_user_id');
  }

  @override
  Future<UserModel?> getCachedSession() async {
    final userIdStr = await secureStorage.read(key: 'cached_user_id');
    if (userIdStr == null) return null;
    
    final userId = int.tryParse(userIdStr);
    if (userId == null) return null;

    final query = appDatabase.select(appDatabase.users)..where((tbl) => tbl.id.equals(userId));
    final userData = await query.getSingleOrNull();
    
    if (userData != null && userData.isActive) {
      return UserModel.fromDrift(userData);
    }
    
    return null;
  }
}