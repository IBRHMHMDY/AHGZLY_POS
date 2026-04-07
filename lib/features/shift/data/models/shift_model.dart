// مسار الملف: lib/features/shift/data/models/shift_model.dart

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
    required super.totalInstapay,
    required super.totalOrders,
    required super.refundedOrdersCount,
    required super.totalRefunds,
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
      // Refactored: تحويل جميع المبالغ إلى int بدلاً من double
      startingCash: (map['starting_cash'] as num?)?.toInt() ?? 0,
      totalSales: (map['total_sales'] as num?)?.toInt() ?? 0,
      totalCash: (map['total_cash'] as num?)?.toInt() ?? 0,
      totalVisa: (map['total_visa'] as num?)?.toInt() ?? 0,
      totalInstapay: (map['total_instapay'] as num?)?.toInt() ?? 0,
      totalOrders: (map['total_orders'] as num?)?.toInt() ?? 0,
      totalRefunds: (map['total_refunds'] as num?)?.toInt() ?? 0,
      refundedOrdersCount: (map['refunded_orders_count'] as num?)?.toInt() ?? 0,
      totalExpenses: (map['total_expenses'] as num?)?.toInt() ?? 0,
      expectedCash: (map['expected_cash'] as num?)?.toInt() ?? 0,
      actualCash: (map['actual_cash'] as num?)?.toInt() ?? 0,
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cashier_id': cashierId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'starting_cash': startingCash, // سيتم الحفظ كـ INTEGER
      'total_sales': totalSales,
      'total_cash': totalCash,
      'total_visa': totalVisa,
      'total_instapay': totalInstapay,
      'total_orders': totalOrders,
      'total_refunds': totalRefunds,
      'refunded_orders_count': refundedOrdersCount,
      'total_expenses': totalExpenses,
      'expected_cash': expectedCash,
      'actual_cash': actualCash,
      'status': status,
    };
  }
}