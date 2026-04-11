import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Refactored: Implement generic UseCase interface
class ToggleUserStatusUseCase implements UseCase<void, ToggleUserStatusParams> {
  final UsersRepository repository;
  ToggleUserStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleUserStatusParams params) async {
    return await repository.toggleUserStatus(params.id, params.isActive);
  }
}

class ToggleUserStatusParams extends Equatable {
  final int id;
  final bool isActive;

  const ToggleUserStatusParams({required this.id, required this.isActive});

  @override
  List<Object> get props => [id, isActive];
}