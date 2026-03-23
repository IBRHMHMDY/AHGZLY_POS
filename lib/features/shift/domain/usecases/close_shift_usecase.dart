import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';

class CloseShiftUseCase implements UseCase<int, ShiftReport> {
  final ShiftRepository repository;

  CloseShiftUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(ShiftReport report) {
    return repository.closeShift(report);
  }
}