import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';

class ShiftReportModel extends ShiftReport {
  const ShiftReportModel({
    required super.totalSales,
    required super.totalCash,
    required super.totalVisa,
    required super.totalInstaPay,
    required super.totalExpenses,
    required super.totalOrders,
  });

  factory ShiftReportModel.fromMap(Map<String, dynamic> map) {
    return ShiftReportModel(
      totalSales: (map['total_sales'] as num?)?.toDouble() ?? 0.0,
      totalCash: (map['total_cash'] as num?)?.toDouble() ?? 0.0,
      totalVisa: (map['total_visa'] as num?)?.toDouble() ?? 0.0,
      totalInstaPay: (map['total_instapay'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (map['total_expenses'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (map['total_orders'] as num?)?.toInt() ?? 0,
    );
  }

  factory ShiftReportModel.fromEntity(ShiftReport entity) {
    return ShiftReportModel(
      totalSales: entity.totalSales,
      totalCash: entity.totalCash,
      totalVisa: entity.totalVisa,
      totalInstaPay: entity.totalInstaPay,
      totalExpenses: entity.totalExpenses,
      totalOrders: entity.totalOrders,
    );
  }
}