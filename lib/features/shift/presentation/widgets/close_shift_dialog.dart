import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloseShiftDialog extends StatefulWidget {
  const CloseShiftDialog({super.key});

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final TextEditingController _actualCashController = TextEditingController();

  void _submit() {
    final text = _actualCashController.text.trim();
    if (text.isEmpty) return;

    final actualCash = double.tryParse(text);
    if (actualCash != null && actualCash >= 0) {
      Navigator.of(context).pop(actualCash); // نُرجع القيمة للشاشة الرئيسية
    }
  }

  @override
  void dispose() {
    _actualCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock_clock, color: Colors.redAccent),
          SizedBox(width: 8),
          Text('إغلاق الوردية'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('الرجاء عدّ النقدية الموجودة في الدرج حالياً وكتابة المبلغ الإجمالي (النقدية الفعلية).'),
          const SizedBox(height: 16),
          TextField(
            controller: _actualCashController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            decoration: const InputDecoration(
              labelText: 'النقدية الفعلية في الدرج (EGP)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.money),
            ),
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // User canceled
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          child: const Text('تأكيد وإغلاق'),
        ),
      ],
    );
  }
}