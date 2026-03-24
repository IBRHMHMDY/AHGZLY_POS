import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/expenses/data/models/expense_model.dart';

abstract class ExpensesLocalDataSource {
  Future<List<ExpenseModel>> getTodayExpenses();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  final DatabaseHelper databaseHelper;

  ExpensesLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<ExpenseModel>> getTodayExpenses() async {
    final db = await databaseHelper.database;
    // نجلب مصروفات اليوم فقط لكي لا نخلط بين الورديات والأيام السابقة
    final result = await db.query(
      'expenses',
      where: 'date(created_at) = date("now", "localtime")',
      orderBy: 'id DESC',
    );
    return result.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final db = await databaseHelper.database;
    await db.insert('expenses', expense.toMap());
  }

  @override
  Future<void> deleteExpense(int id) async {
    final db = await databaseHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}