import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shift.dart';

abstract class ShiftRepository {
  Future<Either<Failure, Shift?>> getActiveShift();
  Future<Either<Failure, Shift>> openShift({required double startingCash, required int cashierId});
  Future<Either<Failure, Shift>> closeShift({required int shiftId, required double actualCash});
}