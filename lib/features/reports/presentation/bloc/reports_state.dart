import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/item_sales_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/report_summary_entity.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  
  @override
  List<Object> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final ReportSummaryEntity summary;
  final List<ItemSalesEntity> itemSales;
  final DateTime startDate;
  final DateTime endDate;

  const ReportsLoaded({
    required this.summary,
    required this.itemSales,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [summary, itemSales, startDate, endDate];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError({required this.message});

  @override
  List<Object> get props => [message];
}