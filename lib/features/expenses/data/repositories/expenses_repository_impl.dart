import 'package:ahgzly_pos/features/expenses/data/datasources/expenses_local_data_source.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:ahgzly_pos/features/expenses/data/models/expense_model.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesLocalDataSource localDataSource;
  ExpensesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Expense>>> getExpenses({required bool isAdmin, required int? shiftId}) async {
    try {
      final expenses = await localDataSource.getExpenses(isAdmin: isAdmin, shiftId: shiftId);
      return Right(expenses);
    } catch (_) {
      return const Left(DatabaseFailure('فشل في جلب قائمة المصروفات.'));
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      await localDataSource.addExpense(ExpenseModel.fromEntity(expense));
      return const Right(null);
    } catch (_) {
      return const Left(DatabaseFailure('فشل في حفظ المصروف. يرجى التأكد من مساحة التخزين.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(int id) async {
    try {
      await localDataSource.deleteExpense(id);
      return const Right(null);
    } catch (_) {
      return const Left(DatabaseFailure('فشل في حذف المصروف.'));
    }
  }
}