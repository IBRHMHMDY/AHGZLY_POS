import 'package:flutter/material.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/core/common/widgets/pos_dialog_components.dart';
import 'package:ahgzly_pos/core/common/widgets/pos_numpad.dart'; 
import 'package:ahgzly_pos/core/common/entities/payment_method_entity.dart';

class CheckoutDialog extends StatefulWidget {
  final int totalAmount; // Total in Cents
  final List<PaymentMethodEntity> paymentMethods;

  const CheckoutDialog({super.key, required this.totalAmount, required this.paymentMethods, });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  int? _selectedPaymentMethodId;
  String _cashInput = '';
  
  @override
  void initState() {
    super.initState();
    if (widget.paymentMethods.isNotEmpty) {
      _selectedPaymentMethodId = widget.paymentMethods.first.id;
    }
  }

  void _onNumpadPressed(String value) {
    if (_cashInput.length < 8) {
      setState(() => _cashInput += value);
    }
  }

  void _onNumpadDelete() {
    if (_cashInput.isNotEmpty) {
      setState(() => _cashInput = _cashInput.substring(0, _cashInput.length - 1));
    }
  }

  void _submit() {
    if (_selectedPaymentMethodId == null) return;
    Navigator.pop(context, _selectedPaymentMethodId);
  }

  @override
  Widget build(BuildContext context) {
    final paidAmountDouble = double.tryParse(_cashInput) ?? 0.0;
    final paidAmountCents = MoneyFormatter.toCents(paidAmountDouble);
    final change = paidAmountCents - widget.totalAmount;
    final selectedMethod = widget.paymentMethods.firstWhere((m) => m.id == _selectedPaymentMethodId, orElse: () => const PaymentMethodEntity(id: 0, name: '', isActive: false));
    final isCashMethod = selectedMethod.name.contains('كاش') || selectedMethod.name.contains('نقد');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: const PosDialogHeader(title: 'إتمام الدفع', icon: Icons.payments_rounded),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: SizedBox(
          width: 800, // شاشة عريضة لتستوعب الـ Numpad وطرق الدفع
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🪄 الجزء الأيمن: طرق الدفع والإجمالي
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          const Text('الإجمالي المطلوب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                          const SizedBox(height: 8),
                          Text('${widget.totalAmount.toFormattedMoney()} ج.م', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.teal.shade900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(alignment: Alignment.centerRight, child: Text('طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 12),
                    ...widget.paymentMethods.map((method) => RadioListTile<int>(
                      title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      value: method.id!,
                      groupValue: _selectedPaymentMethodId,
                      activeColor: Colors.teal,
                      onChanged: (val) {
                        setState(() {
                          _selectedPaymentMethodId = val;
                          _cashInput = ''; // تصفير الإدخال عند تغيير الطريقة
                        });
                      },
                    )),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              Container(width: 2, color: Colors.grey.shade200),
              const SizedBox(width: 24),

              // 🪄 الجزء الأيسر: لوحة الأرقام (تظهر فقط إذا كان الدفع كاش)
              Expanded(
                flex: 1,
                child: isCashMethod ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المدفوع:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('$_cashInput ج.م', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: change >= 0 ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الباقي للعميل:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: change >= 0 ? Colors.green.shade800 : Colors.red.shade800)),
                          Text('${change > 0 ? change.toFormattedMoney() : "0.00"} ج.م', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: change >= 0 ? Colors.green.shade800 : Colors.red.shade800)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 🚀 استخدام المكون المشترك
                    PosNumpad(
                      onNumberPressed: _onNumpadPressed,
                      onDeletePressed: _onNumpadDelete,
                      onSubmitPressed: () {}, // زر الإدخال هنا معطل لأن الاعتماد على زر الحفظ بالأسفل
                      isLoading: false,
                      submitIcon: Icons.backspace,
                    ),
                  ],
                ) : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_rounded, size: 80, color: Colors.orange.shade300),
                      const SizedBox(height: 16),
                      const Text('يتم الدفع عبر البطاقة أو المحفظة.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  )
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          PosDialogActions(
            onCancel: () => Navigator.pop(context), 
            onSubmit: _submit,
            submitText: 'إتمام الطلب والطباعة',
          ),
        ],
      ),
    );
  }
}