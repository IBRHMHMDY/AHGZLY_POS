import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

class ToggleUserStatusUseCase {
  final UsersRepository repository;
  ToggleUserStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, bool isActive) async {
    return await repository.toggleUserStatus(id, isActive);
  }
}