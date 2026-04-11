import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Refactored: Implement UseCase Interface & Add Domain Validation
class CloseShiftUseCase implements UseCase<Shift, CloseShiftParams> {
  final ShiftRepository repository;
  CloseShiftUseCase(this.repository);

  @override
  Future<Either<Failure, Shift>> call(CloseShiftParams params) async {
    if (params.actualCash < 0) {
      return const Left(ValidationFailure('لا يمكن أن يكون المبلغ الفعلي بالسالب'));
    }
    return await repository.closeShift(shiftId: params.shiftId, actualCash: params.actualCash);
  }
}

class CloseShiftParams extends Equatable {
  final int shiftId;
  final int actualCash;

  const CloseShiftParams({required this.shiftId, required this.actualCash});

  @override
  List<Object> get props => [shiftId, actualCash];
}