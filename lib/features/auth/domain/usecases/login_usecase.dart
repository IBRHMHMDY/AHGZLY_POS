import 'package:ahgzly_pos/core/common/users/entities/user.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User, String> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(String pin) async {
    return await repository.login(pin);
  }
}