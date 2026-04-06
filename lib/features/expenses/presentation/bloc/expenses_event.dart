// --- Events ---
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:equatable/equatable.dart';

abstract class ExpensesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadExpensesEvent extends ExpensesEvent {
  final bool isAdmin;
  final int? shiftId;

  LoadExpensesEvent({required this.isAdmin, required this.shiftId});

  @override
  List<Object> get props => [isAdmin, shiftId ?? -1];
}

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

