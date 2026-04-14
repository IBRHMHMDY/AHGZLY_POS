// مسار الملف: lib/features/reports/domain/entities/report_summary_entity.dart
import 'package:equatable/equatable.dart';

class ReportSummaryEntity extends Equatable {
  final double totalSales;
  final double totalExpenses;
  // 🪄 [Refactored]: إضافة تكلفة البضاعة المباعة (Cost of Goods Sold)
  final double totalCogs; 
  final double netProfit;
  final int ordersCount;

  const ReportSummaryEntity({
    required this.totalSales,
    required this.totalExpenses,
    required this.totalCogs, // [Refactored]
    required this.ordersCount,
  }) : netProfit = totalSales - totalCogs - totalExpenses; // 🪄 [Refactored]: تصحيح المعادلة المحاسبية لصافي الربح

  @override
  List<Object> get props => [totalSales, totalExpenses, totalCogs, netProfit, ordersCount];
}