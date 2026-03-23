import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> loginWithPin(String pin);
  Future<Either<Failure, void>> logout();
}