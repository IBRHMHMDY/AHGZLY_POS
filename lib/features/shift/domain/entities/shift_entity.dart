// مسار الملف: lib/features/shift/domain/entities/shift.dart

import 'package:equatable/equatable.dart';

class ShiftEntity extends Equatable {
  final int id;
  final int? cashierId;
  final DateTime startTime;
  final DateTime? endTime;
  
  final int startingCash; // Refactored: int (Cents)
  final int totalOrders;
  final int totalSales; // Refactored: int (Cents)
  final int totalCash; // Refactored: int (Cents)
  final int totalVisa; // Refactored: int (Cents)
  final int totalInstapay; // Refactored: int (Cents)

  final int refundedOrdersCount;
  final int totalRefunds;

  final int totalExpenses; // Refactored: int (Cents)
  
  final int expectedCash; // Refactored: int (Cents)
  final int actualCash; // Refactored: int (Cents)
  final String status;

  const ShiftEntity({
    required this.id,
    this.cashierId,
    required this.startTime,
    this.endTime,
    required this.startingCash,
    required this.totalSales,
    required this.totalCash,
    required this.totalVisa,
    required this.totalInstapay,
    required this.totalRefunds,
    required this.refundedOrdersCount,
    required this.totalOrders,
    required this.totalExpenses,
    required this.expectedCash,
    required this.actualCash,
    required this.status,
  });

  // Refactored: العائد أصبح int
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
