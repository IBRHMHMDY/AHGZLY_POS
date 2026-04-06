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
      // المدير يرى كافة المصروفات المسجلة
      final result = await db.query('expenses', orderBy: 'id DESC');
      return result.map((e) => ExpenseModel.fromMap(e)).toList();
    } else {
      // الكاشير يرى مصروفات ورديته فقط
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
        // 1. التأكد من أن الوردية المحددة نشطة (مفتوحة)
        final shiftResult = await txn.query(
          'shifts',
          where: 'id = ? AND status = ?',
          whereArgs: [expense.shiftId, 'active'],
        );

        if (shiftResult.isEmpty) {
          throw CacheException(message: 'لا يمكن إضافة مصروف: لا توجد وردية نشطة مرتبطة بهذا الإجراء.');
        }

        // 2. إدخال المصروف في جدول المصروفات
        await txn.insert('expenses', expense.toMap());

        // 3. خصم المصروف من الكاش المتوقع (expected_cash) وإضافته لإجمالي المصروفات (total_expenses)
        // يتم هذا داخل نفس الـ Transaction لحماية الأموال
        await txn.rawUpdate('''
          UPDATE shifts 
          SET total_expenses = total_expenses + ?, 
              expected_cash = expected_cash - ? 
          WHERE id = ? AND status = 'active'
        ''', [expense.amount, expense.amount, expense.shiftId]);
      });
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(message: 'حدث خطأ أثناء حفظ المصروف: \$e');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    final db = await databaseHelper.database;
    // ملاحظة تقنية: يجب بحذر التعامل مع حذف المصروفات لأنها تؤثر على حسابات الوردية، 
    // يفضل في التحديثات القادمة إضافة حقل "is_deleted" بدلاً من الحذف النهائي، أو إرجاع المبلغ للوردية.
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}