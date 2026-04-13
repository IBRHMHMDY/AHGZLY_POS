// مسار الملف: lib/features/users/data/datasources/users_local_data_source.dart

import 'package:ahgzly_pos/core/common/users/models/user_model.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; // استيراد Drift
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:drift/drift.dart'; // استيراد مكتبة drift لاستخدام Value

abstract class UsersLocalDataSource {
  Future<List<UserModel>> getUsers();
  Future<void> addUser(String name, String role, String pinHash, String salt);
  Future<void> toggleUserStatus(int id, bool isActive);
}

class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  final AppDatabase appDatabase; // Refactored: استخدام AppDatabase

  UsersLocalDataSourceImpl({required this.appDatabase});

  // Mapper داخلي 
  Map<String, dynamic> _driftUserToMap(UserData driftUser) {
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
  Future<List<UserModel>> getUsers() async {
    try {
      // Refactored: استعلام Drift بدلاً من db.query
      final driftUsers = await (appDatabase.select(appDatabase.users)
            ..where((t) => t.id.isNotValue(1)) // لا نجلب المدير الأساسي
            ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
          .get();

      return driftUsers.map((user) => UserModel.fromMap(_driftUserToMap(user))).toList();
    } catch (e) {
      throw LocalDatabaseException('فشل في جلب المستخدمين: $e');
    }
  }

  @override
  Future<void> addUser(String name, String role, String pinHash, String salt) async {
    try {
      // Refactored: إدخال البيانات باستخدام Drift Companions
      await appDatabase.into(appDatabase.users).insert(
            UsersCompanion.insert(
              name: name,
              role: role,
              pinHash: pinHash,
              salt: salt,
              isActive: const Value(true), // القيمة الافتراضية
              failedAttempts: const Value(0),
            ),
          );
    } catch (e) {
      throw LocalDatabaseException('فشل في إضافة المستخدم: $e');
    }
  }

  @override
  Future<void> toggleUserStatus(int id, bool isActive) async {
    try {
      // Refactored: تحديث حالة المستخدم باستخدام Drift
      await (appDatabase.update(appDatabase.users)
            ..where((t) => t.id.equals(id)))
          .write(
        UsersCompanion(
          isActive: Value(isActive),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('فشل في تحديث حالة المستخدم: $e');
    }
  }
}