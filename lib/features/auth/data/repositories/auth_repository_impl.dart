import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:ahgzly_pos/features/auth/domain/repositories/auth_repository.dart';
import 'package:ahgzly_pos/features/auth/data/datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login(String pin) async {
    try {
      final userModel = await localDataSource.login(pin);
      return Right(userModel); // UserModel inherits from User (Entity)
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return const Left(DatabaseFailure('حدث خطأ أثناء محاولة تسجيل الدخول'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('فشل في مسح بيانات الجلسة السابقة'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final userModel = await localDataSource.getCachedSession();
      return Right(userModel);
    } catch (e) {
      return const Left(CacheFailure('فشل في استرجاع الجلسة السابقة'));
    }
  }
}