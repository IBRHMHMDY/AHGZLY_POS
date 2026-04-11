import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift.dart';
import 'package:dartz/dartz.dart';

// Refactored: Implement UseCase Interface with NoParams
class CheckActiveShiftUseCase implements UseCase<Shift?, NoParams> {
  final ShiftRepository repository;
  CheckActiveShiftUseCase(this.repository);

  @override
  Future<Either<Failure, Shift?>> call(NoParams params) async {
    return await repository.checkActiveShift();
  }
}