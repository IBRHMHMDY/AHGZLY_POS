import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';

// Refactored: Use Params Class
class DeleteExpenseUseCase implements UseCase<void, DeleteExpenseParams> {
  final ExpensesRepository repository;
  DeleteExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteExpenseParams params) {
    return repository.deleteExpense(params.id);
  }
}

class DeleteExpenseParams extends Equatable {
  final int id;
  const DeleteExpenseParams({required this.id});
  
  @override
  List<Object> get props => [id];
}