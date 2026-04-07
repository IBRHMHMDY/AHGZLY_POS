import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:dartz/dartz.dart';


class CloseShiftUseCase {
  final ShiftRepository repository;
  CloseShiftUseCase(this.repository);

  Future<Either<Failure, Shift>> execute({required int shiftId, required int actualCash}) async {
    if (actualCash < 0) return const Left(CacheFailure('النقدية الفعلية لا يمكن أن تكون بالسالب'));
    return await repository.closeShift(shiftId: shiftId, actualCash: actualCash);
  }
}