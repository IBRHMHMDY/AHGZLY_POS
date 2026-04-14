import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/item_sales_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/report_summary_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReportSummaryEntity>> getSummaryReport(DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<ItemSalesEntity>>> getItemSalesReport(DateTime startDate, DateTime endDate);
}