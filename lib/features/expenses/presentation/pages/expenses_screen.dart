import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_bloc.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_event.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';

import 'package:ahgzly_pos/features/expenses/presentation/widgets/add_expense_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpensesBloc>().add(LoadExpensesEvent());
  }

  void _showAddExpenseDialog(BuildContext context) async {
    final bloc = context.read<ExpensesBloc>();
    final newExpense = await showDialog<Expense>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AddExpenseDialog(),
    );

    if (newExpense != null) {
      bloc.add(AddExpenseEvent(newExpense));
    }
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف المصروف', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontSize: 16))),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('تأكيد الحذف'),
            onPressed: () {
              context.read<ExpensesBloc>().add(DeleteExpenseEvent(expense.id!));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.money_off),
            SizedBox(width: 8),
            Text('إدارة المصروفات (درج الكاشير)', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('مصروف جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: () => _showAddExpenseDialog(context),
      ),
      body: BlocConsumer<ExpensesBloc, ExpensesState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            context.read<ExpensesBloc>().add(LoadExpensesEvent());
          } else if (state is ExpensesError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is ExpensesLoading) return const Center(child: CircularProgressIndicator());
          if (state is ExpensesLoaded) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: Colors.redAccent, size: 32),
                              SizedBox(width: 12),
                              Text('إجمالي مصروفات اليوم:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                          Text(
                            '${state.totalExpenses.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: state.expenses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text('لا توجد مصروفات مسجلة اليوم', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: state.expenses.length,
                              itemBuilder: (context, index) {
                                final expense = state.expenses[index];
                                return Card(
                                  elevation: 2,
                                  shadowColor: Colors.black12,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.red.shade50,
                                      child: const Icon(Icons.money_off, color: Colors.redAccent),
                                    ),
                                    title: Text(expense.reason, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    subtitle: Text(
                                      DateTime.parse(expense.createdAt).toString().substring(0, 16),
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${expense.amount} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent)),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _confirmDelete(context, expense),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}