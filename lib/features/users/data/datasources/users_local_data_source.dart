import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:ahgzly_pos/core/common/users/models/user_model.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/utils/extensions/user_role.dart'; 
import 'package:drift/drift.dart'; 

abstract class UsersLocalDataSource {
  Future<List<UserModel>> getUsers();
  Future<void> addUser(String name, UserRole role, String pinHash, String salt); // [Refactored]
  Future<void> toggleUserStatus(int id, bool isActive);
}

class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  final AppDatabase appDatabase; 

  UsersLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final driftUsers = await (appDatabase.select(appDatabase.users)
            ..where((t) => t.id.isNotValue(1))
            ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
          .get();

      // [Refactored]: استخدام Factory الجديد بدون Map وسيط
      return driftUsers.map((user) => UserModel.fromDrift(user)).toList();
    } catch (e) {
      throw CacheException('فشل في جلب المستخدمين: $e');
    }
  }

  @override
  Future<void> addUser(String name, UserRole role, String pinHash, String salt) async {
    try {
      await appDatabase.into(appDatabase.users).insert(
            UsersCompanion.insert(
              name: name,
              role: role.toValue(), // [Refactored]: تحويل الـ Enum لنص لحفظه في قاعدة البيانات
              pinHash: pinHash,
              salt: salt,
              isActive: const Value(true), 
              failedAttempts: const Value(0),
            ),
          );
    } catch (e) {
      throw CacheException('فشل في إضافة المستخدم: $e');
    }
  }

  @override
  Future<void> toggleUserStatus(int id, bool isActive) async {
    try {
      await (appDatabase.update(appDatabase.users)
            ..where((t) => t.id.equals(id)))
          .write(UsersCompanion(isActive: Value(isActive)));
    } catch (e) {
      throw CacheException('فشل في تحديث حالة المستخدم: $e');
    }
  }
}