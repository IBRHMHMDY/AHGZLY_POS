import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:equatable/equatable.dart';

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