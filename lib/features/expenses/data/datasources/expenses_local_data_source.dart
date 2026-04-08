// مسار الملف: lib/features/expenses/data/datasources/expenses_local_data_source.dart

import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/expenses/data/models/expense_model.dart';

abstract class ExpensesLocalDataSource {
  Future<List<ExpenseModel>> getExpenses({required bool isAdmin, required int? shiftId});
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  final DatabaseHelper databaseHelper;

  ExpensesLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<ExpenseModel>> getExpenses({required bool isAdmin, required int? shiftId}) async {
    final db = await databaseHelper.database;
    
    if (isAdmin) {
      final result = await db.query('expenses', orderBy: 'id DESC');
      return result.map((e) => ExpenseModel.fromMap(e)).toList();
    } else {
      if (shiftId == null) return [];
      final result = await db.query(
        'expenses',
        where: 'shift_id = ?',
        whereArgs: [shiftId],
        orderBy: 'id DESC',
      );
      return result.map((e) => ExpenseModel.fromMap(e)).toList();
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final db = await databaseHelper.database;
    
    try {
      await db.transaction((txn) async {
        final shiftResult = await txn.query(
          'shifts',
          where: 'id = ? AND status = ?',
          whereArgs: [expense.shiftId, 'active'],
        );

        if (shiftResult.isEmpty) {
          throw CacheException(message: 'لا يمكن إضافة مصروف: لا توجد وردية نشطة.');
        }

        await txn.insert('expenses', expense.toMap());

        await txn.rawUpdate('''
          UPDATE shifts 
          SET total_expenses = total_expenses + ?, 
              expected_cash = expected_cash - ? 
          WHERE id = ? AND status = 'active'
        ''', [expense.amount, expense.amount, expense.shiftId]);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'حدث خطأ أثناء حفظ المصروف: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    final db = await databaseHelper.database;
    
    try {
      // [Refactoring Specialist]: استخدام Transaction لضمان عودة المبلغ لدرج النقدية عند حذف المصروف بالخطأ
      await db.transaction((txn) async {
        final expResult = await txn.query('expenses', where: 'id = ?', whereArgs: [id]);
        if (expResult.isEmpty) {
          throw CacheException(message: 'لم يتم العثور على المصروف.');
        }
        
        final expense = expResult.first;
        final int amount = (expense['amount'] as num).toInt();
        final int shiftId = (expense['shift_id'] as num).toInt();

        // 1. حذف المصروف
        await txn.delete('expenses', where: 'id = ?', whereArgs: [id]);

        // 2. إرجاع المبلغ لحسابات الوردية (تقليل إجمالي المصروفات وزيادة الدرج)
        await txn.rawUpdate('''
          UPDATE shifts 
          SET total_expenses = total_expenses - ?, 
              expected_cash = expected_cash + ? 
          WHERE id = ? AND status = 'active'
        ''', [amount, amount, shiftId]);
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'حدث خطأ أثناء حذف المصروف: ${e.toString()}');
    }
  }
}