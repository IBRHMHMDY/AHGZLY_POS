import 'package:ahgzly_pos/core/common/users/entities/user.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String pin);
  Future<Either<Failure, void>> logout();
}