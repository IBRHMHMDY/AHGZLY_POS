import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloseShiftDialog extends StatefulWidget {
  final int expectedCash;

  const CloseShiftDialog({super.key, required this.expectedCash});

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final TextEditingController _actualCashController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _difference = 0;
  bool _isCalculated = false;

  @override
  void initState() {
    super.initState();
    _actualCashController.addListener(_calculateDifference);
  }

  void _calculateDifference() {
    final actualCashDouble = double.tryParse(_actualCashController.text);
    if (actualCashDouble != null) {
      final actualCashCents = MoneyFormatter.toCents(actualCashDouble);
      setState(() {
        _difference = actualCashCents - widget.expectedCash;
        _isCalculated = true;
      });
    } else {
      setState(() => _isCalculated = false);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final actualCashDouble = double.parse(_actualCashController.text.trim());
      final actualCashCents = MoneyFormatter.toCents(actualCashDouble);
      Navigator.of(context).pop(actualCashCents);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: const _DialogHeader(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: SizedBox(
          width: 450,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ExpectedCashBox(expectedCash: widget.expectedCash),
                const SizedBox(height: 20),
                const Text('الرجاء عدّ النقدية الموجودة في الدرج حالياً وكتابة المبلغ الفعلي لإتمام المطابقة.', style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildActualCashInput(),
                if (_isCalculated) ...[
                  const SizedBox(height: 20),
                  _DifferenceBox(difference: _difference),
                ],
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          _DialogActions(onCancel: () => Navigator.of(context).pop(), onSubmit: _submit),
        ],
      ),
    );
  }

  Widget _buildActualCashInput() {
    return TextFormField(
      controller: _actualCashController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
      decoration: InputDecoration(
        labelText: 'النقدية الفعلية (بعد العد)',
        labelStyle: TextStyle(color: Colors.teal.shade700, fontSize: 16),
        filled: true,
        fillColor: Colors.teal.shade50.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: const BorderRadius.horizontal(right: Radius.circular(10))),
          child: Icon(Icons.money, color: Colors.teal.shade800),
        ),
      ),
      autofocus: true,
      validator: (val) {
        if (val == null || val.isEmpty) return 'أدخل النقدية الفعلية';
        if (double.tryParse(val) == null) return 'رقم غير صحيح';
        return null;
      },
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
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle),
            child: Icon(Icons.lock_clock, color: Colors.red.shade800, size: 28),
          ),
          const SizedBox(width: 12),
          Text('إغلاق الوردية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red.shade900)),
        ],
      ),
    );
  }
}

class _ExpectedCashBox extends StatelessWidget {
  final int expectedCash;
  const _ExpectedCashBox({required this.expectedCash});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('الكاش المتوقع بالدرج:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
          Text('${MoneyFormatter.format(expectedCash)} ج.م', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.teal.shade800)),
        ],
      ),
    );
  }
}

class _DifferenceBox extends StatelessWidget {
  final int difference;
  const _DifferenceBox({required this.difference});

  @override
  Widget build(BuildContext context) {
    final color = difference == 0 ? Colors.green : (difference > 0 ? Colors.teal : Colors.red);
    final text = difference == 0 ? 'الدرج مطابق تماماً' : (difference > 0 ? 'يوجد زيادة قدرها:' : 'يوجد عجز قدره:');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color, width: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.shade800)),
          if (difference != 0) Text('${MoneyFormatter.format(difference.abs())} ج.م', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color.shade800)),
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
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2),
            icon: const Icon(Icons.print),
            label: const Text('إغلاق وطباعة Z-Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}