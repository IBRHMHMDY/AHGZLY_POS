import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/auth/domain/entities/user.dart';
import 'package:ahgzly_pos/features/auth/domain/repositories/auth_repository.dart';
import 'package:ahgzly_pos/features/auth/data/datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login(String pin) async {
    try {
      final user = await localDataSource.login(pin);
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure('فشل تسجيل الدخول: الرمز السري غير صحيح'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // في نظام الـ Offline لا نحتاج لحذف توكن، فقط تنظيف الحالة في الـ Bloc
    return const Right(null);
  }
}