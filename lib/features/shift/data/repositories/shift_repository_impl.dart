import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';
import 'package:ahgzly_pos/features/shift/domain/repositories/shift_repository.dart';
import 'package:ahgzly_pos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:ahgzly_pos/features/shift/data/models/shift_report_model.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftLocalDataSource localDataSource;

  ShiftRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ShiftReport>> getZReport() async {
    try {
      final report = await localDataSource.getZReport();
      return Right(report);
    } catch (e) {
      return Left(DatabaseFailure('فشل في استخراج تقرير الوردية: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> closeShift(ShiftReport report) async {
    try {
      final reportModel = ShiftReportModel.fromEntity(report);
      final shiftId = await localDataSource.closeShift(reportModel);
      return Right(shiftId);
    } catch (e) {
      return Left(DatabaseFailure('فشل في حفظ وتقفيل الوردية: ${e.toString()}'));
    }
  }
}