import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense_entity.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class AddExpenseUseCase implements UseCase<void, AddExpenseParams> {
  final ExpensesRepository repository;
  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddExpenseParams params) async {
    // 🛡️ حماية مالية: يمنع تسجيل مصروف بصفر أو بالسالب
    if (params.expense.amount <= 0) {
      return const Left(ValidationFailure('لا يمكن إضافة مصروف بقيمة صفر أو قيمة سالبة'));
    }
    // 🛡️ حماية البيانات: يمنع تسجيل مصروف بدون وصف
    if (params.expense.reason.trim().isEmpty) {
      return const Left(ValidationFailure('يجب كتابة وصف للمصروف'));
    }
    return await repository.addExpense(params.expense);
  }
}

class AddExpenseParams extends Equatable {
  final ExpenseEntity expense;
  const AddExpenseParams({required this.expense});
  
  @override
  List<Object> get props => [expense];
}