// مسار الملف: lib/features/shift/data/models/shift_model.dart

import 'package:ahgzly_pos/core/database/app_database.dart'; // [Added] لاستخدام ShiftData
import '../../domain/entities/shift_entity.dart';

class ShiftModel extends ShiftEntity {
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

  // [Refactor]: قراءة البيانات مباشرة من Drift بدون الحاجة لـ Map أو DateTime.parse
  factory ShiftModel.fromDrift(ShiftData data) {
    return ShiftModel(
      id: data.id,
      cashierId: data.cashierId,
      startTime: data.startTime, // يعود كـ DateTime تلقائياً
      endTime: data.endTime,     // يعود كـ DateTime تلقائياً
      startingCash: data.startingCash,
      totalSales: data.totalSales,
      totalCash: data.totalCash,
      totalVisa: data.totalVisa,
      totalInstapay: data.totalInstapay,
      totalOrders: data.totalOrders,
      totalRefunds: data.totalRefunds,
      refundedOrdersCount: data.refundedOrdersCount,
      totalExpenses: data.totalExpenses,
      expectedCash: data.expectedCash,
      actualCash: data.actualCash,
      status: data.status,
    );
  }
}