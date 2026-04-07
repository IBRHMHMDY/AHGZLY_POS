// مسار الملف: lib/features/shift/domain/entities/shift.dart

import 'package:equatable/equatable.dart';

class Shift extends Equatable {
  final int id;
  final int? cashierId;
  final DateTime startTime;
  final DateTime? endTime;
  final int startingCash;  // Refactored: int (Cents)
  final int totalSales;    // Refactored: int (Cents)
  final int totalCash;     // Refactored: int (Cents)
  final int totalVisa;     // Refactored: int (Cents)
  final int totalInstapay; // Refactored: int (Cents)
  final int totalOrders;
  final int totalExpenses; // Refactored: int (Cents)
  final int expectedCash;  // Refactored: int (Cents)
  final int actualCash;    // Refactored: int (Cents)
  final String status;

  const Shift({
    required this.id,
    this.cashierId,
    required this.startTime,
    this.endTime,
    required this.startingCash,
    required this.totalSales,
    required this.totalCash,
    required this.totalVisa,
    required this.totalInstapay,
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
        id, cashierId, startTime, endTime, startingCash, totalSales,
        totalCash, totalVisa, totalInstapay, totalOrders, totalExpenses, 
        expectedCash, actualCash, status,
      ];
}