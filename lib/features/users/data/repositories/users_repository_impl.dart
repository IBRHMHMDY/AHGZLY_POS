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
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addUser({
    required String name,
    required String role,
    required String pin,
  }) async {
    try {
      // 1. توليد Salt فريد لهذا المستخدم
      final salt = HashUtil.generateSalt();
      
      // 2. تشفير الـ PIN المكتوب مع الـ Salt باستخدام HashUtil
      final pinHash = HashUtil.generatePinHash(pin, salt);
      
      // 3. حفظ البيانات المشفرة في قاعدة البيانات (الـ PIN الأصلي لا يُحفظ أبداً)
      await localDataSource.addUser(name, role, pinHash, salt);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUserStatus(int id, bool isActive) async {
    try {
      await localDataSource.toggleUserStatus(id, isActive);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}