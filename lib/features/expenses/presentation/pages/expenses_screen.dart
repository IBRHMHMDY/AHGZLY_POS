
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_bloc.dart';

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

  void _showAddExpenseDialog(BuildContext context) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final bloc = context.read<ExpensesBloc>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل مصروف جديد', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ (ج.م)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'سبب الصرف (أنابيب، خضار، إلخ)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.red))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () {
                if (amountController.text.isNotEmpty && reasonController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  bloc.add(AddExpenseEvent(Expense(
                    amount: amount,
                    reason: reasonController.text,
                    createdAt: DateTime.now().toIso8601String(),
                  )));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ المصروف'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المصروفات (درج الكاشير)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('مصروف جديد'),
        onPressed: () => _showAddExpenseDialog(context),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<ExpensesBloc, ExpensesState>(
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
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.red.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('إجمالي مصروفات اليوم:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                        Text('${state.totalExpenses.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: state.expenses.isEmpty
                        ? const Center(child: Text('لا توجد مصروفات مسجلة اليوم', style: TextStyle(fontSize: 18, color: Colors.grey)))
                        : ListView.builder(
                            itemCount: state.expenses.length,
                            itemBuilder: (context, index) {
                              final expense = state.expenses[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.money_off, color: Colors.white)),
                                  title: Text(expense.reason, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  subtitle: Text(DateTime.parse(expense.createdAt).toString().substring(0, 16)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${expense.amount} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.grey),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: AlertDialog(
                                                title: const Text('حذف المصروف'),
                                                content: const Text('هل أنت متأكد من الحذف؟'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                    onPressed: () {
                                                      context.read<ExpensesBloc>().add(DeleteExpenseEvent(expense.id!));
                                                      Navigator.pop(ctx);
                                                    },
                                                    child: const Text('حذف'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}