import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';

class GetZReportUseCase implements UseCase<ShiftReport, NoParams> {
  final ShiftRepository repository;

  GetZReportUseCase(this.repository);

  @override
  Future<Either<Failure, ShiftReport>> call(NoParams params) {
    return repository.getZReport();
  }
}