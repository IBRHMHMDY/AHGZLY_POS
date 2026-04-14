import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Refactored: Implement generic UseCase interface and strict Params
class AddUserUseCase implements UseCase<void, AddUserParams> {
  final UsersRepository repository;
  AddUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddUserParams params) async {
    // Domain-level validation as a final security layer
    if (params.pin.length < 4) {
      return const Left(ValidationFailure('الرمز السري يجب أن يكون 4 أرقام على الأقل'));
    }
    return await repository.addUser(
      name: params.name,
      role: params.role,
      pin: params.pin,
    );
  }
}

class AddUserParams extends Equatable {
  final String name;
  final UserRole role;
  final String pin;

  const AddUserParams({required this.name, required this.role, required this.pin});

  @override
  List<Object> get props => [name, role, pin];
}