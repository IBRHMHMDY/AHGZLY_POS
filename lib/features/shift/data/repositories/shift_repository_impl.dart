import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:dartz/dartz.dart';


class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftLocalDataSource localDataSource;

  ShiftRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Shift?>> checkActiveShift() async {
    try {
      final shift = await localDataSource.getActiveShift();
      return Right(shift);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(CacheFailure('حدث خطأ أثناء جلب حالة الوردية.'));
    }
  }

  @override
  Future<Either<Failure, Shift>> openShift({required int startingCash, required int cashierId}) async {
    try {
      final shift = await localDataSource.openShift(startingCash: startingCash, cashierId: cashierId);
      return Right(shift);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(CacheFailure('فشل في فتح الوردية.'));
    }
  }

  @override
  Future<Either<Failure, Shift>> closeShift({required int shiftId, required double actualCash}) async {
    try {
      final shift = await localDataSource.closeShift(shiftId: shiftId, actualCash: actualCash);
      return Right(shift);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(CacheFailure('فشل في إغلاق الوردية.'));
    }
  }
}