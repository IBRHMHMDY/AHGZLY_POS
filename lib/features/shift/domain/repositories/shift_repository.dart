import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';

abstract class ShiftRepository {
  Future<Either<Failure, ShiftReport>> getZReport();
  Future<Either<Failure, int>> closeShift(ShiftReport report);
}