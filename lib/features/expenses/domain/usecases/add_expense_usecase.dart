import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:ahgzly_pos/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/check_active_shift_usecase.dart';
import 'package:dartz/dartz.dart';

class AddExpenseUseCase {
  final ExpensesRepository expensesRepository;
  final CheckActiveShiftUseCase checkActiveShiftUseCase;

  AddExpenseUseCase({
    required this.expensesRepository,
    required this.checkActiveShiftUseCase,
  });

  Future<Either<Failure, void>> call(Expense expense) async {
    final shiftResult = await checkActiveShiftUseCase.execute();
    
    return shiftResult.fold(
      (failure) => Left(failure),
      (activeShift) async {
        if (activeShift == null) {
          return const Left(CacheFailure('لا يمكن إضافة مصروف: لا توجد وردية مفتوحة حالياً.'));
        }

        final expenseWithShift = Expense(
          id: expense.id,
          shiftId: activeShift.id, 
          amount: expense.amount,
          reason: expense.reason,
          createdAt: expense.createdAt,
        );

        return await expensesRepository.addExpense(expenseWithShift);
      },
    );
  }
}