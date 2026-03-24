import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';

class DeleteExpenseUseCase implements UseCase<void, int> {
  final ExpensesRepository repository;

  DeleteExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) {
    return repository.deleteExpense(id);
  }
}