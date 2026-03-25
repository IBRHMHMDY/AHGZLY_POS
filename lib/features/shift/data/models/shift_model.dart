import '../../domain/entities/shift.dart';

class ShiftModel extends Shift {
  const ShiftModel({
    required super.id,
    super.cashierId,
    required super.startTime,
    super.endTime,
    required super.startingCash,
    required super.totalSales,
    required super.totalCash,
    required super.totalVisa,
    required super.totalInstapay, // تمت الإضافة
    required super.totalOrders,   // تمت الإضافة
    required super.totalExpenses,
    required super.expectedCash,
    required super.actualCash,
    required super.status,
  });

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      id: map['id'],
      cashierId: map['cashier_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      startingCash: (map['starting_cash'] ?? 0).toDouble(),
      totalSales: (map['total_sales'] ?? 0).toDouble(),
      totalCash: (map['total_cash'] ?? 0).toDouble(),
      totalVisa: (map['total_visa'] ?? 0).toDouble(),
      totalInstapay: (map['total_instapay'] ?? 0).toDouble(), // تمت الإضافة
      totalOrders: (map['total_orders'] ?? 0).toInt(),       // تمت الإضافة
      totalExpenses: (map['total_expenses'] ?? 0).toDouble(),
      expectedCash: (map['expected_cash'] ?? 0).toDouble(),
      actualCash: (map['actual_cash'] ?? 0).toDouble(),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cashier_id': cashierId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'starting_cash': startingCash,
      'total_sales': totalSales,
      'total_cash': totalCash,
      'total_visa': totalVisa,
      'total_instapay': totalInstapay, // تمت الإضافة
      'total_orders': totalOrders,     // تمت الإضافة
      'total_expenses': totalExpenses,
      'expected_cash': expectedCash,
      'actual_cash': actualCash,
      'status': status,
    };
  }
}