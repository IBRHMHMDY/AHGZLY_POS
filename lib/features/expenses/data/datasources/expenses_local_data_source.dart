import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/expenses/data/models/expense_model.dart';
import 'package:drift/drift.dart';

abstract class ExpensesLocalDataSource {
  Future<List<ExpenseModel>> getExpenses({required bool isAdmin, required int? shiftId});
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  final AppDatabase appDatabase; 

  ExpensesLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<List<ExpenseModel>> getExpenses({required bool isAdmin, required int? shiftId}) async {
    try {
      List<ExpenseData> driftExpenses;
      
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
      
      // [Refactored]: استخدام fromDrift بدلاً من Map
      return driftExpenses.map((e) => ExpenseModel.fromDrift(e)).toList();
    } catch (e) {
      throw CacheException('فشل في جلب المصروفات: $e');
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await appDatabase.transaction(() async {
        final shift = await (appDatabase.select(appDatabase.shifts)
              ..where((t) => t.id.equals(expense.shiftId) & t.status.equals('active')))
            .getSingleOrNull();

        if (shift == null) throw CacheException('لا يمكن إضافة مصروف: لا توجد وردية نشطة.');

        await appDatabase.into(appDatabase.expenses).insert(
          ExpensesCompanion.insert(
            shiftId: expense.shiftId,
            amount: expense.amount,
            reason: expense.reason,
            createdAt: expense.createdAt, // [Refactored]: يُمرر كـ DateTime مباشرة
          ),
        );

        final updatedShift = shift.copyWith(
          totalExpenses: shift.totalExpenses + expense.amount,
          expectedCash: shift.expectedCash - expense.amount,
        );

        await appDatabase.update(appDatabase.shifts).replace(updatedShift);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('حدث خطأ أثناء حفظ المصروف: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    // ... (هذه الدالة تبقى كما هي لديك لأنها سليمة وتؤدي عملها بشكل ممتاز)
    try {
      await appDatabase.transaction(() async {
        final expense = await (appDatabase.select(appDatabase.expenses)..where((t) => t.id.equals(id))).getSingleOrNull();
        if (expense == null) throw CacheException('لم يتم العثور على المصروف.');
        final shift = await (appDatabase.select(appDatabase.shifts)..where((t) => t.id.equals(expense.shiftId) & t.status.equals('active'))).getSingleOrNull();
        if (shift != null) {
          final updatedShift = shift.copyWith(
            totalExpenses: shift.totalExpenses - expense.amount,
            expectedCash: shift.expectedCash + expense.amount,
          );
          await appDatabase.update(appDatabase.shifts).replace(updatedShift);
        }
        await (appDatabase.delete(appDatabase.expenses)..where((t) => t.id.equals(id))).go();
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('حدث خطأ أثناء حذف المصروف: ${e.toString()}');
    }
  }
}