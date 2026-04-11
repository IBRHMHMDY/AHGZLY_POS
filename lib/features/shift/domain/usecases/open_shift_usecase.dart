import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Refactored: Implement UseCase Interface & Add Domain Validation
class OpenShiftUseCase implements UseCase<Shift, OpenShiftParams> {
  final ShiftRepository repository;
  OpenShiftUseCase(this.repository);

  @override
  Future<Either<Failure, Shift>> call(OpenShiftParams params) async {
    if (params.startingCash < 0) {
      return const Left(ValidationFailure('لا يمكن أن تكون العهدة الافتتاحية بالسالب'));
    }
    return await repository.openShift(userId: params.userId, startingCash: params.startingCash);
  }
}

class OpenShiftParams extends Equatable {
  final int userId;
  final int startingCash;

  const OpenShiftParams({required this.userId, required this.startingCash});

  @override
  List<Object> get props => [userId, startingCash];
}