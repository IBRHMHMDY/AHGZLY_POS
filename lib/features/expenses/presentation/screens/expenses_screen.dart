import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_bloc.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_event.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_state.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense_entity.dart';
import 'package:ahgzly_pos/features/expenses/presentation/widgets/add_expense_dialog.dart';
import 'package:ahgzly_pos/core/common/widgets/custom_shimmer.dart'; // 🪄 استيراد الشيمر

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    final shiftState = context.read<ShiftBloc>().state;
    
    final bool isAdmin = (authState is AuthAuthenticated) && authState.user.isAdmin;
    final int? shiftId = (shiftState is ActiveShiftLoaded) ? shiftState.shift.id : null;
    
    context.read<ExpensesBloc>().add(LoadExpensesEvent(isAdmin: isAdmin, shiftId: shiftId));
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _showAddExpenseDialog(BuildContext context) async {
    final bloc = context.read<ExpensesBloc>();
    final newExpense = await showDialog<ExpenseEntity>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AddExpenseDialog(),
    );

    if (newExpense != null) {
      bloc.add(AddExpenseEvent(newExpense));
    }
  }

  void _confirmDelete(BuildContext context, ExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('حذف المصروف', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟ لا يمكن التراجع عن هذا الإجراء.', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('إلغاء', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold))
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.delete_forever),
            label: const Text('تأكيد الحذف', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (state is ExpensesSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            _loadData();
          } else if (state is ExpensesError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is ExpensesLoading) return const _ExpensesShimmerLoading(); // 🪄 الشيمر الاحترافي
          
          if (state is ExpensesLoaded) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _ExpenseSummaryCard(totalExpenses: state.totalExpenses),
                    Expanded(
                      child: state.expenses.isEmpty
                          ? const _EmptyExpensesView()
                          : _ExpenseList(expenses: state.expenses, onDelete: (expense) => _confirmDelete(context, expense)),
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

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets)
// ==========================================

class _ExpenseSummaryCard extends StatelessWidget {
  final int totalExpenses;
  const _ExpenseSummaryCard({required this.totalExpenses});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100, width: 2),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
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
            '${MoneyFormatter.format(totalExpenses)} ج.م',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<ExpenseEntity> expenses;
  final ValueChanged<ExpenseEntity> onDelete;

  const _ExpenseList({required this.expenses, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade50,
              radius: 24,
              child: const Icon(Icons.money_off, color: Colors.redAccent),
            ),
            title: Text(expense.reason, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(
              DateTime.parse(expense.createdAt).toString().substring(0, 16),
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${MoneyFormatter.format(expense.amount)} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.redAccent)),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDelete(expense),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyExpensesView extends StatelessWidget {
  const _EmptyExpensesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا توجد مصروفات مسجلة اليوم', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ExpensesShimmerLoading extends StatelessWidget {
  const _ExpensesShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: CustomShimmer.rectangular(height: 90, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                itemBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomShimmer.rectangular(height: 80, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}