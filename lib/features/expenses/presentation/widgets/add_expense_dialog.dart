import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_bloc.dart';
import 'package:ahgzly_pos/features/expenses/presentation/bloc/expenses_event.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';
import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.money_off, color: Colors.redAccent),
          SizedBox(width: 8),
          Text('تسجيل مصروف جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'المبلغ (ج.م)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.teal),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'أدخل المبلغ';
                if (double.tryParse(val) == null) return 'رقم غير صحيح';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'سبب الصرف (فواتير كهرباء، غاز... إلخ)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.edit_note, color: Colors.teal),
              ),
              validator: (val) => (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              final shiftState = context.read<ShiftBloc>().state;
    int currentShiftId = 0;
    if (shiftState is ActiveShiftLoaded) {
      currentShiftId = shiftState.shift.id; // جلب رقم الوردية الحالية
    }
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm a');
    final newExpense = Expense(
      shiftId: currentShiftId, // ⬅️ ربط المصروف بالوردية هنا!
      amount: amount,
      reason: _reasonController.text,
      createdAt:dateFormat.format(DateTime.now()),
    );

    context.read<ExpensesBloc>().add(AddExpenseEvent(newExpense));
              Navigator.pop(context, newExpense);
            }
          },
          child: const Text('حفظ المصروف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}