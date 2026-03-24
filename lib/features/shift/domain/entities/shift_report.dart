import 'package:equatable/equatable.dart';

class ShiftReport extends Equatable {
  final double totalSales;
  final double totalCash;
  final double totalVisa;
  final double totalInstaPay;
  final double totalExpenses; // إضافة إجمالي المصروفات
  final int totalOrders;

  const ShiftReport({
    required this.totalSales,
    required this.totalCash,
    required this.totalVisa,
    required this.totalInstaPay,
    required this.totalExpenses,
    required this.totalOrders,
  });

  @override
  List<Object?> get props => [
        totalSales,
        totalCash,
        totalVisa,
        totalInstaPay,
        totalExpenses,
        totalOrders,
      ];
}