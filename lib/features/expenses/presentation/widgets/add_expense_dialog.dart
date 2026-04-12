import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final shiftState = context.read<ShiftBloc>().state;
      if (shiftState is! ActiveShiftLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن تسجيل مصروف بدون فتح وردية!'), backgroundColor: Colors.red),
        );
        return;
      }

      final amountDouble = double.parse(_amountController.text);
      final expense = Expense(
        amount: MoneyFormatter.toCents(amountDouble),
        reason: _reasonController.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
        shiftId: shiftState.shift.id,
      );
      Navigator.pop(context, expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: const _DialogHeader(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        content: SizedBox(
          width: 450,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAmountInput(),
                const SizedBox(height: 20),
                _buildReasonInput(),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          _DialogActions(onCancel: () => Navigator.pop(context), onSubmit: _submit),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.redAccent),
      decoration: InputDecoration(
        labelText: 'مبلغ المصروف',
        labelStyle: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.red.shade50.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
        suffixText: 'ج.م',
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: const BorderRadius.horizontal(right: Radius.circular(10))),
          child: Icon(Icons.attach_money, color: Colors.red.shade800),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'أدخل المبلغ';
        if (double.tryParse(val) == null || double.parse(val) <= 0) return 'رقم غير صحيح';
        return null;
      },
    );
  }

  Widget _buildReasonInput() {
    return TextFormField(
      controller: _reasonController,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: 'سبب الصرف (فاتورة كهرباء، شراء خامات...)',
        labelStyle: TextStyle(color: Colors.teal.shade700),
        filled: true,
        fillColor: Colors.teal.shade50.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: const BorderRadius.horizontal(right: Radius.circular(10))),
          child: Icon(Icons.edit_note, color: Colors.teal.shade800),
        ),
      ),
      validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال سبب المصروف' : null,
    );
  }
}

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets)
// ==========================================

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle),
            child: Icon(Icons.money_off_rounded, color: Colors.red.shade800, size: 28),
          ),
          const SizedBox(width: 12),
          Text('تسجيل مصروف جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red.shade900)),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _DialogActions({required this.onCancel, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('حفظ المصروف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}