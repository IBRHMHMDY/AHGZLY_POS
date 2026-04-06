import 'package:ahgzly_pos/core/common/entities/user.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

class GetUsersUseCase {
  final UsersRepository repository;
  GetUsersUseCase(this.repository);

  Future<Either<Failure, List<User>>> call() async {
    return await repository.getUsers();
  }
}