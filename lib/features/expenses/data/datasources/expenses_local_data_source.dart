// مسار الملف: lib/features/expenses/data/datasources/expenses_local_data_source.dart

import 'package:ahgzly_pos/core/database/drift/app_database.dart'; // استيراد Drift
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/expenses/data/models/expense_model.dart';
import 'package:drift/drift.dart';

abstract class ExpensesLocalDataSource {
  Future<List<ExpenseModel>> getExpenses({required bool isAdmin, required int? shiftId});
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  final AppDatabase appDatabase; // Refactored: استخدام AppDatabase

  ExpensesLocalDataSourceImpl({required this.appDatabase});

  // Mapper لتحويل كائن Drift إلى Map يقبله Model
  Map<String, dynamic> _driftExpenseToMap(ExpenseDrift driftExpense) {
    return {
      'id': driftExpense.id,
      'shift_id': driftExpense.shiftId,
      'amount': driftExpense.amount,
      'reason': driftExpense.reason,
      'created_at': driftExpense.createdAt,
    };
  }

  @override
  Future<List<ExpenseModel>> getExpenses({required bool isAdmin, required int? shiftId}) async {
    try {
      List<ExpenseDrift> driftExpenses;
      
      if (isAdmin) {
        driftExpenses = await (appDatabase.select(appDatabase.expenses)
              ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
            .get();
      } else {
        if (shiftId == null) return [];
        driftExpenses = await (appDatabase.select(appDatabase.expenses)
              ..where((t) => t.shiftId.equals(shiftId))
              ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
            .get();
      }
      
      return driftExpenses.map((e) => ExpenseModel.fromMap(_driftExpenseToMap(e))).toList();
    } catch (e) {
      throw CacheException(message: 'فشل في جلب المصروفات: $e');
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      // استخدام Transaction لضمان تزامن حفظ المصروف وخصمه من الدرج
      await appDatabase.transaction(() async {
        // 1. جلب الوردية والتحقق من نشاطها
        final shift = await (appDatabase.select(appDatabase.shifts)
              ..where((t) => t.id.equals(expense.shiftId) & t.status.equals('active')))
            .getSingleOrNull();

        if (shift == null) {
          throw CacheException(message: 'لا يمكن إضافة مصروف: لا توجد وردية نشطة.');
        }

        // 2. إدخال المصروف الجديد
        await appDatabase.into(appDatabase.expenses).insert(
          ExpensesCompanion.insert(
            shiftId: expense.shiftId,
            amount: expense.amount,
            reason: expense.reason,
            createdAt: expense.createdAt,
          ),
        );

        // 3. تحديث حسابات الوردية (تقليل العهدة المتوقعة وزيادة المصروفات)
        final updatedShift = shift.copyWith(
          totalExpenses: shift.totalExpenses + expense.amount,
          expectedCash: shift.expectedCash - expense.amount,
        );

        await appDatabase.update(appDatabase.shifts).replace(updatedShift);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'حدث خطأ أثناء حفظ المصروف: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    try {
      await appDatabase.transaction(() async {
        // 1. جلب المصروف المراد حذفه لمعرفة قيمته
        final expense = await (appDatabase.select(appDatabase.expenses)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();

        if (expense == null) {
          throw CacheException(message: 'لم يتم العثور على المصروف.');
        }

        // 2. جلب الوردية الخاصة بهذا المصروف
        final shift = await (appDatabase.select(appDatabase.shifts)
              ..where((t) => t.id.equals(expense.shiftId) & t.status.equals('active')))
            .getSingleOrNull();

        // 3. إذا كانت الوردية لا تزال نشطة، نقوم بإرجاع المبلغ للدرج وتقليل المصروفات
        if (shift != null) {
          final updatedShift = shift.copyWith(
            totalExpenses: shift.totalExpenses - expense.amount,
            expectedCash: shift.expectedCash + expense.amount,
          );
          await appDatabase.update(appDatabase.shifts).replace(updatedShift);
        }

        // 4. حذف المصروف نهائياً
        await (appDatabase.delete(appDatabase.expenses)
              ..where((t) => t.id.equals(id)))
            .go();
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'حدث خطأ أثناء حذف المصروف: ${e.toString()}');
    }
  }
}