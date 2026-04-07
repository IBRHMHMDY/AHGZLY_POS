import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloseShiftDialog extends StatefulWidget {
  final int expectedCash; // تمت إضافة هذا المتغير لحساب الفروقات

  const CloseShiftDialog({super.key, required this.expectedCash});

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final TextEditingController _actualCashController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _difference = 0; // Refactored: التعامل مع الفرق كـ int
  bool _isCalculated = false;

  @override
  void initState() {
    super.initState();
    _actualCashController.addListener(_calculateDifference);
  }

  void _calculateDifference() {
    final actualCashDouble = double.tryParse(_actualCashController.text);
    if (actualCashDouble != null) {
      // تحويل الإدخال (جنيهات) إلى قروش للخصم الدقيق من المتوقع
      final actualCashCents = MoneyFormatter.toCents(actualCashDouble);
      setState(() {
        _difference = actualCashCents - widget.expectedCash;
        _isCalculated = true;
      });
    } else {
      setState(() {
        _isCalculated = false;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final actualCashDouble = double.parse(_actualCashController.text.trim());
      final actualCashCents = MoneyFormatter.toCents(actualCashDouble);
      Navigator.of(
        context,
      ).pop(actualCashCents); // إرجاع القيمة بالقروش للـ BLoC
    }
  }

  @override
  void dispose() {
    _actualCashController.removeListener(_calculateDifference);
    _actualCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.redAccent, size: 28),
            SizedBox(width: 8),
            Text(
              'إغلاق الوردية',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الكاش المتوقع بالدرج:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${MoneyFormatter.format(widget.expectedCash)} ج.م',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'الرجاء عدّ النقدية الموجودة في الدرج حالياً وكتابة المبلغ الفعلي لإتمام المطابقة.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _actualCashController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'النقدية الفعلية (بعد العد)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.money, color: Colors.teal),
                  ),
                  autofocus: true,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      {return 'أدخل النقدية الفعلية';}
                    if (double.tryParse(val) == null) return 'رقم غير صحيح';
                    return null;
                  },
                ),
                if (_isCalculated) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _difference == 0
                          ? Colors.green.shade50
                          : (_difference > 0
                                ? Colors.teal.shade50
                                : Colors.red.shade50),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _difference == 0
                            ? Colors.green
                            : (_difference > 0 ? Colors.teal : Colors.red),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _difference == 0
                              ? 'الدرج مطابق تماماً'
                              : (_difference > 0
                                    ? 'يوجد زيادة قدرها:'
                                    : 'يوجد عجز قدره:'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _difference == 0
                                ? Colors.green.shade800
                                : (_difference > 0
                                      ? Colors.teal.shade800
                                      : Colors.red.shade800),
                          ),
                        ),
                        if (_difference != 0)
                          Text(
                            '${MoneyFormatter.format(_difference.abs())} ج.م',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _difference > 0
                                  ? Colors.teal.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.print),
            label: const Text(
              'إغلاق وطباعة Z-Report',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
