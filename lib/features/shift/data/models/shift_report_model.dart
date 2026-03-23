import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';

class ShiftReportModel extends ShiftReport {
  const ShiftReportModel({
    required super.startTime,
    required super.endTime,
    required super.totalCash,
    required super.totalVisa,
    required super.totalInstaPay,
    required super.totalSales,
    required super.totalOrders,
  });

  factory ShiftReportModel.fromEntity(ShiftReport entity) {
    return ShiftReportModel(
      startTime: entity.startTime,
      endTime: entity.endTime,
      totalCash: entity.totalCash,
      totalVisa: entity.totalVisa,
      totalInstaPay: entity.totalInstaPay,
      totalSales: entity.totalSales,
      totalOrders: entity.totalOrders,
    );
  }
}