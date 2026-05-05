import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:dartz/dartz.dart';

class GetShiftsHistoryUseCase implements UseCase<List<ShiftEntity>, NoParams> {
  final ShiftRepository repository;

  GetShiftsHistoryUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ShiftEntity>>> call(NoParams params) async {
    return await repository.getShiftsHistory();
  }
}
