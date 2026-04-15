import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:equatable/equatable.dart';

class ShiftEntity extends Equatable {
  final int id;
  final int? cashierId;
  final DateTime startTime;
  final DateTime? endTime;

  final int startingCash;
  final int totalOrders;
  final int totalSales;
  final int totalCash;
  final int totalVisa;
  final int totalInstapay;

  final int refundedOrdersCount;
  final int totalRefunds;

  final int totalExpenses;

  final int expectedCash;
  final int actualCash;
  final ShiftStatus status;

  const ShiftEntity({
    required this.id,
    this.cashierId,
    required this.startTime,
    this.endTime,
    required this.startingCash,
    this.totalSales = 0, // 🪄 [Refactored] قيم افتراضية آمنة
    this.totalCash = 0,
    this.totalVisa = 0,
    this.totalInstapay = 0,
    this.totalRefunds = 0,
    this.refundedOrdersCount = 0,
    this.totalOrders = 0,
    this.totalExpenses = 0,
    this.expectedCash = 0,
    this.actualCash = 0,
    required this.status,
  });

  // العجز أو الزيادة في الدرج
  int get shortageOrOverage => actualCash - expectedCash;

  @override
  List<Object?> get props => [
    id,
    cashierId,
    startTime,
    endTime,
    startingCash,
    totalSales,
    refundedOrdersCount,
    totalRefunds,
    totalCash,
    totalVisa,
    totalInstapay,
    totalOrders,
    totalExpenses,
    expectedCash,
    actualCash,
    status,
  ];
}
