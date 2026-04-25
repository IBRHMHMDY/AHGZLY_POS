import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:ahgzly_pos/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.pin);
  }
}

class LoginParams extends Equatable {
  final String pin;
  
  const LoginParams({required this.pin});

  @override
  List<Object> get props => [pin];
}