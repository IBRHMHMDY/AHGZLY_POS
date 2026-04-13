import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart'; 
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login(String pin) async {
    try {
      final user = await localDataSource.loginWithPin(pin);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      // Refactored: Use AuthFailure instead of CacheFailure for unknown auth errors
      return Left(AuthFailure('حدث خطأ غير متوقع أثناء تسجيل الدخول.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      // Refactored: Ensure consistent failure usage
      return Left(AuthFailure('فشل تسجيل الخروج. يرجى المحاولة لاحقاً.'));
    }
  }
}