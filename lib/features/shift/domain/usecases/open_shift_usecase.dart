import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:dartz/dartz.dart';


class OpenShiftUseCase {
  final ShiftRepository repository;
  OpenShiftUseCase(this.repository);

  Future<Either<Failure, Shift>> execute({required int startingCash, required int cashierId}) async {
    if (startingCash < 0) return const Left(CacheFailure('العهدة لا يمكن أن تكون بالسالب'));
    return await repository.openShift(startingCash: startingCash, cashierId: cashierId);
  }
}