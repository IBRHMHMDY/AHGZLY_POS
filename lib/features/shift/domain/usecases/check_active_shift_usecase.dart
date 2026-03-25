import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:dartz/dartz.dart';


class CheckActiveShiftUseCase {
  final ShiftRepository repository;
  CheckActiveShiftUseCase(this.repository);

  Future<Either<Failure, Shift?>> execute() async {
    return await repository.getActiveShift();
  }
}