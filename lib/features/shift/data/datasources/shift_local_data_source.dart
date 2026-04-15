import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/shift/data/models/shift_model.dart';
import 'package:drift/drift.dart';

abstract class ShiftLocalDataSource {
  Future<ShiftModel?> getActiveShift();
  Future<ShiftModel> openShift({required int startingCash, required int cashierId});
  Future<ShiftModel> closeShift({required int shiftId, required int actualCash});
}

class ShiftLocalDataSourceImpl implements ShiftLocalDataSource {
  final AppDatabase appDatabase; 

  ShiftLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<ShiftModel?> getActiveShift() async {
    try {
      final shift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.status.equals(ShiftStatus.active.name)))
          .getSingleOrNull();

      if (shift != null) return ShiftModel.fromDrift(shift);
      return null;
    } catch (e) {
      throw CacheException('فشل في جلب الوردية النشطة: $e'); 
    }
  }

  @override
  Future<ShiftModel> openShift({required int startingCash, required int cashierId}) async {
    try {
      final id = await appDatabase.into(appDatabase.shifts).insert(
            ShiftsCompanion.insert(
              cashierId: Value(cashierId),
              startTime: DateTime.now(), 
              startingCash: Value(startingCash),
              expectedCash: Value(startingCash), // يبدأ العهدة بالمبلغ الافتتاحي
              status: ShiftStatus.active.name,
            ),
          );

      final newShift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.id.equals(id))).getSingle();

      return ShiftModel.fromDrift(newShift);
    } catch (e) {
      throw CacheException('فشل في فتح الوردية: $e');
    }
  }

  @override
  Future<ShiftModel> closeShift({required int shiftId, required int actualCash}) async {
    try {
      // 1. جلب بيانات الوردية الحالية لمعرفة وقت البداية
      final shift = await (appDatabase.select(appDatabase.shifts)..where((t) => t.id.equals(shiftId))).getSingle();
      final endTime = DateTime.now();

      // 2. 🪄 [Refactored]: جلب جميع الطلبات والمصروفات التي تمت خلال فترة الوردية فقط
      final orders = await (appDatabase.select(appDatabase.orders)
            ..where((t) => t.createdAt.isBiggerOrEqualValue(shift.startTime.toIso8601String()))).get();
            
      final expenses = await (appDatabase.select(appDatabase.expenses)
            ..where((t) => t.createdAt.isBiggerOrEqualValue(shift.startTime.toIso8601String()))).get();

      // 3. 🪄 [Refactored]: محرك تجميع بيانات الوردية (Aggregations)
      int totalSales = 0;
      int totalCash = 0;
      int totalVisa = 0;
      int totalInstapay = 0;
      int totalRefunds = 0;
      int refundedOrdersCount = 0;
      int totalExpenses = 0;

      for (var order in orders) {
        if (order.status == OrderStatus.completed) {
          totalSales += order.netSales; // نستخدم صافي المبيعات (بدون ضرائب) بناءً على المرحلة 1
          if (order.paymentMethod == PaymentMethod.cash) totalCash += order.total; // النقدية في الدرج شاملة الضرائب
          if (order.paymentMethod == PaymentMethod.visa) totalVisa += order.total;
          if (order.paymentMethod == PaymentMethod.wallet) totalInstapay += order.total;
        } else if (order.status == OrderStatus.refunded) {
          totalRefunds += order.total;
          refundedOrdersCount++;
        }
      }

      for (var expense in expenses) {
        totalExpenses += expense.amount;
      }

      // 4. حساب النقدية المتوقعة في الدرج بدقة متناهية
      // (الافتتاحي + المبيعات النقدية - المرتجعات النقدية - المصروفات)
      int expectedCash = shift.startingCash + totalCash - totalRefunds - totalExpenses;

      // 5. حفظ كل هذه العمليات في قاعدة البيانات وتحديث حالة الوردية
      await (appDatabase.update(appDatabase.shifts)..where((t) => t.id.equals(shiftId))).write(
        ShiftsCompanion(
          endTime: Value(endTime),
          totalSales: Value(totalSales),
          totalCash: Value(totalCash),
          totalVisa: Value(totalVisa),
          totalInstapay: Value(totalInstapay),
          totalRefunds: Value(totalRefunds),
          refundedOrdersCount: Value(refundedOrdersCount),
          totalOrders: Value(orders.length),
          totalExpenses: Value(totalExpenses),
          expectedCash: Value(expectedCash),
          actualCash: Value(actualCash),
          status: Value(ShiftStatus.closed.name),
        ),
      );

      final updatedShift = await (appDatabase.select(appDatabase.shifts)..where((t) => t.id.equals(shiftId))).getSingle();
      return ShiftModel.fromDrift(updatedShift);

    } catch (e) {
      throw CacheException('فشل في إغلاق الوردية وحساب الإجماليات: $e');
    }
  }
}