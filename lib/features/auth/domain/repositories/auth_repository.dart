import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String pin);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCachedUser();
}