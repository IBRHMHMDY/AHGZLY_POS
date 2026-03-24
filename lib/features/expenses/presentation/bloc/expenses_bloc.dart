import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/get_today_expenses_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/delete_expense_usecase.dart';

// --- Events ---
abstract class ExpensesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadExpensesEvent extends ExpensesEvent {}

class AddExpenseEvent extends ExpensesEvent {
  final Expense expense;
  AddExpenseEvent(this.expense);
  @override
  List<Object> get props => [expense];
}

class DeleteExpenseEvent extends ExpensesEvent {
  final int id;
  DeleteExpenseEvent(this.id);
  @override
  List<Object> get props => [id];
}

// --- States ---
abstract class ExpensesState extends Equatable {
  @override
  List<Object> get props => [];
}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<Expense> expenses;
  final double totalExpenses;
  ExpensesLoaded(this.expenses, this.totalExpenses);
  @override
  List<Object> get props => [expenses, totalExpenses];
}

class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError(this.message);
  @override
  List<Object> get props => [message];
}

class ExpenseOperationSuccess extends ExpensesState {
  final String message;
  ExpenseOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

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