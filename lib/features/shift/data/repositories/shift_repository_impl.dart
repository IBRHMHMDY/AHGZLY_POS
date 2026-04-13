import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftLocalDataSource localDataSource;

  ShiftRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ShiftEntity?>> checkActiveShift() async {
    try {
      final shift = await localDataSource.getActiveShift();
      return Right(shift);
    } on LocalDatabaseException catch (_) {
      // Refactored: User-friendly error message
      return const Left(DatabaseFailure('حدث خطأ أثناء التحقق من الوردية النشطة. يرجى المحاولة لاحقاً.'));
    }
  }

  @override
  Future<Either<Failure, ShiftEntity>> openShift({required int userId, required int startingCash}) async {
    try {
      final shift = await localDataSource.openShift(cashierId: userId,startingCash: startingCash);
      return Right(shift);
    } on LocalDatabaseException catch (_) {
      return const Left(DatabaseFailure('فشل في فتح الوردية. تأكد من مساحة التخزين الخاصة بالجهاز.'));
    }
  }

  @override
  Future<Either<Failure, ShiftEntity>> closeShift({required int shiftId, required int actualCash}) async {
    try {
      final shift = await localDataSource.closeShift(shiftId: shiftId, actualCash: actualCash);
      return Right(shift);
    } on LocalDatabaseException catch (_) {
      return const Left(DatabaseFailure('فشل في إغلاق الوردية. يرجى مراجعة الحسابات وتكرار المحاولة.'));
    }
  }
}