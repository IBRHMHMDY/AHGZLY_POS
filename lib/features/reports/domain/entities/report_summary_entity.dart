import 'package:equatable/equatable.dart';

class ReportSummaryEntity extends Equatable {
  final int netSales;       // المبيعات الصافية (إيراد المطعم الفعلي الخالي من الضرائب)
  final int totalCollected; // إجمالي النقدية في الدرج (شاملة الضرائب والرسوم)
  final int totalExpenses;  // المصروفات
  final int totalCogs;      // تكلفة البضاعة المباعة (COGS)
  final int netProfit;      // صافي الربح الفعلي
  final int ordersCount;    // عدد الطلبات

  const ReportSummaryEntity({
    required this.netSales,
    required this.totalCollected,
    required this.totalExpenses,
    required this.totalCogs,
    required this.ordersCount,
  }) : netProfit = netSales - totalCogs - totalExpenses; 
  // المعادلة الدقيقة: الإيراد الفعلي - التكلفة - المصروفات

  @override
  List<Object> get props => [
        netSales,
        totalCollected,
        totalExpenses,
        totalCogs,
        netProfit,
        ordersCount,
      ];
}