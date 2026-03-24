import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';

abstract class ExpensesRepository {
  Future<Either<Failure, List<Expense>>> getTodayExpenses();
  Future<Either<Failure, void>> addExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(int id);
}