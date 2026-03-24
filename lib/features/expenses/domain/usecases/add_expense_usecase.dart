import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';

class AddExpenseUseCase implements UseCase<void, Expense> {
  final ExpensesRepository repository;

  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense expense) {
    return repository.addExpense(expense);
  }
}