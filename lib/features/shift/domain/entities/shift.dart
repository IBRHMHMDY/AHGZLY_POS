import 'package:equatable/equatable.dart';

class Shift extends Equatable {
  final int id;
  final int? cashierId;
  final DateTime startTime;
  final DateTime? endTime;
  final double startingCash;
  final double totalSales;
  final double totalCash;
  final double totalVisa;
  final double totalInstapay;
  final int totalOrders;
  final double totalExpenses;
  final double expectedCash;
  final double actualCash;
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

  double get shortageOrOverage => actualCash - expectedCash;

  @override
  List<Object?> get props => [
        id, cashierId, startTime, endTime, startingCash, totalSales,
        totalCash, totalVisa, totalInstapay, totalOrders, totalExpenses, 
        expectedCash, actualCash, status,
      ];
}