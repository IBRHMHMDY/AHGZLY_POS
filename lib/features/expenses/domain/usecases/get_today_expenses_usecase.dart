import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';

class GetTodayExpensesUseCase implements UseCase<List<Expense>, NoParams> {
  final ExpensesRepository repository;

  GetTodayExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams params) {
    return repository.getTodayExpenses();
  }
}