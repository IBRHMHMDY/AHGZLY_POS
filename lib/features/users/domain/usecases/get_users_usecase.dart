import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

// Refactored: Implement generic UseCase interface with NoParams
class GetUsersUseCase implements UseCase<List<User>, NoParams> {
  final UsersRepository repository;
  GetUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(NoParams params) async {
    return await repository.getUsers();
  }
}