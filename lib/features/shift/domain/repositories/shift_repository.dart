import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shift_entity.dart';

abstract class ShiftRepository {
  Future<Either<Failure, ShiftEntity?>> checkActiveShift();
  Future<Either<Failure, ShiftEntity>> openShift({required int userId, required int startingCash});
  Future<Either<Failure, ShiftEntity>> closeShift({required int shiftId, required int actualCash});
  Future<Either<Failure, List<ShiftEntity>>> getShiftsHistory({int limit = 50, int offset = 0}); // 🚀 [Sprint 2]
}