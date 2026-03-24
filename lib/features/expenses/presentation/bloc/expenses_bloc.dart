import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_event.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/get_today_expenses_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/delete_expense_usecase.dart';

// --- BLoC ---
class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final GetTodayExpensesUseCase getTodayExpensesUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  ExpensesBloc({
    required this.getTodayExpensesUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(ExpensesInitial()) {
    
    on<LoadExpensesEvent>((event, emit) async {
      emit(ExpensesLoading());
      final result = await getTodayExpensesUseCase(NoParams());
      result.fold(
        (failure) => emit(ExpensesError(failure.message)),
        (expenses) {
          double total = 0.0;
          for (var e in expenses) {
            total += e.amount;
          }
          emit(ExpensesLoaded(expenses, total));
        },
      );
    });

    on<AddExpenseEvent>((event, emit) async {
      emit(ExpensesLoading());
      final result = await addExpenseUseCase(event.expense);
      result.fold(
        (failure) => emit(ExpensesError(failure.message)),
        (_) => emit(ExpenseOperationSuccess('تم تسجيل المصروف بنجاح')),
      );
    });

    on<DeleteExpenseEvent>((event, emit) async {
      emit(ExpensesLoading());
      final result = await deleteExpenseUseCase(event.id);
      result.fold(
        (failure) => emit(ExpensesError(failure.message)),
        (_) => emit(ExpenseOperationSuccess('تم حذف المصروف بنجاح')),
      );
    });
  }
}