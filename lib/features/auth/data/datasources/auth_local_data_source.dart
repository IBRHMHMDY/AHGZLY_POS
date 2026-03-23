import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> loginWithPin(String pin);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper databaseHelper;

  AuthLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<UserModel> loginWithPin(String pin) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'users',
      where: 'pin = ?',
      whereArgs: [pin],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    } else {
      throw Exception('الرمز السري غير صحيح');
    }
  }
}