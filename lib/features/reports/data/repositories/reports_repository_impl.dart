import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/reports/data/datasource/reports_local_data_source.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/item_sales_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/report_summary_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/repositories/reports_repository.dart';
import 'package:dartz/dartz.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsLocalDataSource localDataSource;

  ReportsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ReportSummaryEntity>> getSummaryReport(DateTime startDate, DateTime endDate) async {
    try {
      // 🪄 نستلم الـ Model (Data) ونرجعه كـ Entity (Domain)
      final model = await localDataSource.getSummaryReport(startDate, endDate);
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure('حدث خطأ أثناء حساب ملخص التقارير: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ItemSalesEntity>>> getItemSalesReport(DateTime startDate, DateTime endDate) async {
    try {
      final models = await localDataSource.getItemSalesReport(startDate, endDate);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('حدث خطأ أثناء استخراج مبيعات الأصناف: $e'));
    }
  }
}