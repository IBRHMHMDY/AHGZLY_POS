import 'package:ahgzly_pos/core/common/entities/user.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/utils/hash_util.dart';
import 'package:ahgzly_pos/features/users/data/datasources/users_local_data_source.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersLocalDataSource localDataSource;

  UsersRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final users = await localDataSource.getUsers();
      return Right(users);
    } on LocalDatabaseException catch (_) {
      // Refactored: Prevent raw exception details from reaching the UI
      return const Left(DatabaseFailure('حدث خطأ أثناء جلب قائمة المستخدمين. يرجى المحاولة لاحقاً.'));
    }
  }

  @override
  Future<Either<Failure, void>> addUser({
    required String name,
    required String role,
    required String pin,
  }) async {
    try {
      final salt = HashUtil.generateSalt();
      final pinHash = HashUtil.generatePinHash(pin, salt);
      
      await localDataSource.addUser(name, role, pinHash, salt);
      return const Right(null);
    } on LocalDatabaseException catch (_) {
      // Refactored: Clear Arabic error message
      return const Left(DatabaseFailure('فشل في حفظ بيانات المستخدم. قد يكون هناك مشكلة في مساحة التخزين.'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUserStatus(int id, bool isActive) async {
    try {
      await localDataSource.toggleUserStatus(id, isActive);
      return const Right(null);
    } on LocalDatabaseException catch (_) {
      return const Left(DatabaseFailure('فشل في تحديث حالة المستخدم. تأكد من اتصال قاعدة البيانات.'));
    }
  }
}