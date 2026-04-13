import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:dartz/dartz.dart';

// Refactored: Implement UseCase Interface with NoParams
class CheckActiveShiftUseCase implements UseCase<ShiftEntity?, NoParams> {
  final ShiftRepository repository;
  CheckActiveShiftUseCase(this.repository);

  @override
  Future<Either<Failure, ShiftEntity?>> call(NoParams params) async {
    return await repository.checkActiveShift();
  }
}