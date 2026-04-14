import 'package:equatable/equatable.dart';

class ReportSummaryEntity extends Equatable {
  final double totalSales;
  final double totalExpenses;
  final double netProfit;
  final int ordersCount;

  const ReportSummaryEntity({
    required this.totalSales,
    required this.totalExpenses,
    required this.ordersCount,
  }) : netProfit = totalSales - totalExpenses; // حساب تلقائي لصافي الربح

  @override
  List<Object> get props => [totalSales, totalExpenses, netProfit, ordersCount];
}