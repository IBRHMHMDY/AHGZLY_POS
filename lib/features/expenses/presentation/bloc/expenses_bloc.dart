import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:ahgzly_pos/features/expenses/domain/usecases/get_today_expenses_usecase.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_event.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetTodayExpensesUseCase getTodayExpensesUseCase;

  ExpensesBloc({
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.getTodayExpensesUseCase,
  }) : super(ExpensesInitial()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  // 1. معالجة جلب مصروفات اليوم
  Future<void> _onLoadExpenses(LoadExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final result = await getTodayExpensesUseCase(GetExpensesParams(isAdmin: event.isAdmin, shiftId: event.shiftId));
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (expenses) {
        final int totalExpenses = expenses.fold(0, (sum, item) => sum + item.amount);
        emit(ExpensesLoaded(expenses, totalExpenses));
      },
    );
  }

  // 2. معالجة إضافة مصروف جديد (وخصمه من الوردية)
  Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    
    final result = await addExpenseUseCase(event.expense);
    
    result.fold(
      (failure) {
        emit(ExpensesError(failure.message));
      },
      (_) {
        emit(ExpensesSuccess('تم إضافة المصروف بنجاح وخصمه من الوردية.'));
        // استدعاء حدث الجلب لتحديث القائمة فوراً بعد النجاح
        add(LoadExpensesEvent(isAdmin: true, shiftId: event.expense.shiftId));
      },
    );
  }

  // 3. معالجة حذف مصروف
  Future<void> _onDeleteExpense(DeleteExpenseEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    
    final result = await deleteExpenseUseCase(event.id);
    
    result.fold(
      (failure) {
        emit(ExpensesError(failure.message));
      },
      (_) {
        emit(ExpensesSuccess('تم حذف المصروف بنجاح.'));
        // استدعاء حدث الجلب لتحديث القائمة فوراً بعد الحذف
        add(LoadExpensesEvent(isAdmin: true, shiftId: event.id));
      },
    );
  }
}