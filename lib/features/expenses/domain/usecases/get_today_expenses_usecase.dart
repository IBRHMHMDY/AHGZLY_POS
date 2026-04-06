import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';

class GetExpensesParams {
  final bool isAdmin;
  final int? shiftId;
  GetExpensesParams({required this.isAdmin, required this.shiftId});
}

class GetTodayExpensesUseCase implements UseCase<List<Expense>, GetExpensesParams> {
  final ExpensesRepository repository;
  GetTodayExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(GetExpensesParams params) {
    return repository.getExpenses(isAdmin: params.isAdmin, shiftId: params.shiftId);
  }
}