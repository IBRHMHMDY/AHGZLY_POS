import 'package:equatable/equatable.dart';

class ShiftReport extends Equatable {
  final String startTime;
  final String endTime;
  final double totalCash;
  final double totalVisa;
  final double totalInstaPay;
  final double totalSales;
  final int totalOrders;

  const ShiftReport({
    required this.startTime,
    required this.endTime,
    required this.totalCash,
    required this.totalVisa,
    required this.totalInstaPay,
    required this.totalSales,
    required this.totalOrders,
  });

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        totalCash,
        totalVisa,
        totalInstaPay,
        totalSales,
        totalOrders,
      ];
}