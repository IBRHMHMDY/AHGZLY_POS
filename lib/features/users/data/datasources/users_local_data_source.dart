import 'package:ahgzly_pos/core/common/models/user_model.dart';
import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';

abstract class UsersLocalDataSource {
  Future<List<UserModel>> getUsers();
  Future<void> addUser(String name, String role, String pinHash, String salt);
  Future<void> toggleUserStatus(int id, bool isActive);
}

class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  final DatabaseHelper databaseHelper;

  UsersLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final db = await databaseHelper.database;
      // لا نجلب المدير الأساسي لكي لا يحذفه أحد بالخطأ (id = 1)
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id != ?',
        whereArgs: [1],
        orderBy: 'id DESC',
      );
      return maps.map((map) => UserModel.fromMap(map)).toList();
    } catch (e) {
      throw LocalDatabaseException('فشل في جلب المستخدمين: $e');
    }
  }

  @override
  Future<void> addUser(String name, String role, String pinHash, String salt) async {
    try {
      final db = await databaseHelper.database;
      await db.insert('users', {
        'name': name,
        'role': role,
        'pin_hash': pinHash,
        'salt': salt,
        'is_active': 1,
        'failed_attempts': 0,
      });
    } catch (e) {
      throw LocalDatabaseException('فشل في إضافة المستخدم: $e');
    }
  }

  @override
  Future<void> toggleUserStatus(int id, bool isActive) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'users',
        {'is_active': isActive ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw LocalDatabaseException('فشل في تحديث حالة المستخدم: $e');
    }
  }
}