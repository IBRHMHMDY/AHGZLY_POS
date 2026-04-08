// مسار الملف: lib/features/shift/data/datasources/shift_local_data_source.dart

import 'package:ahgzly_pos/core/database/drift/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/shift/data/models/shift_model.dart';
import 'package:drift/drift.dart';

abstract class ShiftLocalDataSource {
  Future<ShiftModel?> getActiveShift();
  // تم تصحيح الأنواع المعادة لتكون ShiftModel بدلاً من int أو void
  Future<ShiftModel> openShift({required int startingCash, required int cashierId});
  Future<ShiftModel> closeShift({required int shiftId, required int actualCash});
}

class ShiftLocalDataSourceImpl implements ShiftLocalDataSource {
  final AppDatabase appDatabase; 

  ShiftLocalDataSourceImpl({required this.appDatabase});

  // Mapper لتحويل كائن Drift إلى Map
  Map<String, dynamic> _driftShiftToMap(dynamic driftShift) {
    return {
      'id': driftShift.id,
      'cashier_id': driftShift.cashierId,
      'start_time': driftShift.startTime,
      'end_time': driftShift.endTime,
      'starting_cash': driftShift.startingCash, 
      'total_sales': driftShift.totalSales,
      'total_cash': driftShift.totalCash,
      'total_visa': driftShift.totalVisa,
      'total_instapay': driftShift.totalInstapay,
      'total_orders': driftShift.totalOrders,
      'total_refunds': driftShift.totalRefunds,
      'refunded_orders_count': driftShift.refundedOrdersCount,
      'total_expenses': driftShift.totalExpenses,
      'expected_cash': driftShift.expectedCash,
      'actual_cash': driftShift.actualCash,
      'status': driftShift.status, 
    };
  }

  @override
  Future<ShiftModel?> getActiveShift() async {
    try {
      final shift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.status.equals('active')))
          .getSingleOrNull();

      if (shift != null) {
        return ShiftModel.fromMap(_driftShiftToMap(shift));
      }
      return null;
    } catch (e) {
      throw LocalDatabaseException('فشل في جلب الوردية النشطة: $e');
    }
  }

  @override
  Future<ShiftModel> openShift({required int startingCash, required int cashierId}) async {
    try {
      // 1. إدخال الوردية الجديدة
      final id = await appDatabase.into(appDatabase.shifts).insert(
            ShiftsCompanion.insert(
              cashierId: Value(cashierId),
              startTime: DateTime.now().toIso8601String(),
              startingCash: Value(startingCash),
              expectedCash: Value(startingCash), 
              status: 'active', 
            ),
          );

      // 2. جلب الوردية التي تم إنشاؤها للتو لإرجاعها ككائن كامل
      final newShift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.id.equals(id)))
          .getSingle();

      return ShiftModel.fromMap(_driftShiftToMap(newShift));
    } catch (e) {
      throw LocalDatabaseException('فشل في فتح الوردية: $e');
    }
  }

  @override
  Future<ShiftModel> closeShift({required int shiftId, required int actualCash}) async {
    try {
      // 1. تحديث الوردية وإغلاقها
      await (appDatabase.update(appDatabase.shifts)
            ..where((t) => t.id.equals(shiftId)))
          .write(
        ShiftsCompanion(
          endTime: Value(DateTime.now().toIso8601String()),
          actualCash: Value(actualCash),
          status: const Value('closed'),
        ),
      );

      // 2. جلب الوردية المحدثة لإرجاعها للـ Repository
      final updatedShift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.id.equals(shiftId)))
          .getSingle();

      return ShiftModel.fromMap(_driftShiftToMap(updatedShift));
    } catch (e) {
      throw LocalDatabaseException('فشل في إغلاق الوردية: $e');
    }
  }
}