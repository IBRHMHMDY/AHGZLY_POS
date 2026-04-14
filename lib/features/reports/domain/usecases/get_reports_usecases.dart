import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/item_sales_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/report_summary_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/repositories/reports_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetSummaryReportUseCase implements UseCase<ReportSummaryEntity, ReportDateParams> {
  final ReportsRepository repository;
  GetSummaryReportUseCase(this.repository);

  @override
  Future<Either<Failure, ReportSummaryEntity>> call(ReportDateParams params) async {
    return await repository.getSummaryReport(params.startDate, params.endDate);
  }
}

class GetItemSalesReportUseCase implements UseCase<List<ItemSalesEntity>, ReportDateParams> {
  final ReportsRepository repository;
  GetItemSalesReportUseCase(this.repository);

  @override
  Future<Either<Failure, List<ItemSalesEntity>>> call(ReportDateParams params) async {
    return await repository.getItemSalesReport(params.startDate, params.endDate);
  }
}

class ReportDateParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const ReportDateParams({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}