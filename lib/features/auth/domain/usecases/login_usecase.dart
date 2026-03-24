import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/auth/domain/entities/user.dart';
import 'package:ahgzly_pos/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User, String> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(String pin) {
    return repository.login(pin);
  }
}