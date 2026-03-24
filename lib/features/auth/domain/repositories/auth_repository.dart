import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  // تم توحيد المسمى ليكون login بدلاً من التشتت السابق
  Future<Either<Failure, User>> login(String pin);
  Future<Either<Failure, void>> logout();
}