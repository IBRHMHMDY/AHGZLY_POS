import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/utils/hash_util.dart';
import 'package:ahgzly_pos/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String pin);
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper dbHelper;

  AuthLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<UserModel> login(String pin) async {
    try {
      final db = await dbHelper.database;
      
      // تشفير الـ PIN المدخل من قبل المستخدم قبل البحث في قاعدة البيانات
      final String hashedPin = HashUtil.generatePinHash(pin);

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'pin = ?',
        whereArgs: [hashedPin],
      );

      if (maps.isNotEmpty) {
        return UserModel.fromMap(maps.first);
      } else {
        throw Exception('الرقم السري غير صحيح');
      }
    } catch (e) {
      throw Exception('خطأ في قاعدة البيانات: $e');
    }
  }

  @override
  Future<void> logout() async {
    // يمكن إضافة منطق إضافي هنا لتسجيل الخروج (مثلاً مسح التوكن أو الجلسة الحالية من الذاكرة)
    return Future.value();
  }
}