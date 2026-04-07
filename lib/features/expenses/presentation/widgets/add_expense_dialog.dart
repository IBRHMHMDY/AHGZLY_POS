import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
// 1. استيراد الـ Bloc الخاص بالوردية
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';

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
              
              // 2. التحقق من وجود وردية نشطة وجلب رقمها (ID)
              final shiftState = context.read<ShiftBloc>().state;
              if (shiftState is! ActiveShiftLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لا يمكن تسجيل مصروف بدون فتح وردية!'), 
                    backgroundColor: Colors.red
                  ),
                );
                return;
              }

              final amountDouble = double.parse(_amountController.text);
              final expense = Expense(
                amount: MoneyFormatter.toCents(amountDouble),
                reason: _reasonController.text.trim(),
                createdAt: DateTime.now().toIso8601String(), // صيغة صحيحة 100%
                shiftId: shiftState.shift.id, // ⬅️ تم وضع رقم الوردية الفعلي هنا
              );
              Navigator.pop(context, expense);
            }
          },
          child: const Text('حفظ المصروف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}