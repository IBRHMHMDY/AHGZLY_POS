import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:dartz/dartz.dart';

class GetShiftsHistoryParams {
  final int limit;
  final int offset;

  GetShiftsHistoryParams({this.limit = 50, this.offset = 0});
}

class GetShiftsHistoryUseCase implements UseCase<List<ShiftEntity>, GetShiftsHistoryParams> {
  final ShiftRepository repository;

  GetShiftsHistoryUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ShiftEntity>>> call(GetShiftsHistoryParams params) async {
    return await repository.getShiftsHistory(limit: params.limit, offset: params.offset);
  }
}
