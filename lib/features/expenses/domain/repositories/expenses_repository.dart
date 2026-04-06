import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';

abstract class ExpensesRepository {
  // الجلب يطلب الصلاحية ورقم الوردية
  Future<Either<Failure, List<Expense>>> getExpenses({required bool isAdmin, required int? shiftId});
  
  // الإضافة تطلب المصروف فقط
  Future<Either<Failure, void>> addExpense(Expense expense);
  
  // الحذف يطلب الـ ID فقط
  Future<Either<Failure, void>> deleteExpense(int id);
}