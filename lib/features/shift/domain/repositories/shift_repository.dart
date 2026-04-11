import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shift.dart';

abstract class ShiftRepository {
  Future<Either<Failure, Shift?>> checkActiveShift();
  Future<Either<Failure, Shift>> openShift({required int userId, required int startingCash});
  Future<Either<Failure, Shift>> closeShift({required int shiftId, required int actualCash});
}