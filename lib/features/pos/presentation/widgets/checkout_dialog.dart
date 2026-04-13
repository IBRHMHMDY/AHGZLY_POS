// مسار الملف: lib/features/pos/presentation/widgets/checkout_dialog.dart

import 'package:ahgzly_pos/core/common/enums/enums_data.dart';

import 'package:ahgzly_pos/core/extensions/payment_method.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';

class CheckoutDialog extends StatefulWidget {
  final int totalAmount;
  final OrderType orderType;

  const CheckoutDialog({
    super.key,
    required this.totalAmount,
    required this.orderType,
  });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // 🪄 [Refactored]: استخدام الـ Enum بشكل مباشر بدلاً من النصوص
  PaymentMethod _selectedMethod = PaymentMethod.cash; 
  
  late TextEditingController _paidController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  int _change = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paidController = TextEditingController(text: MoneyFormatter.format(widget.totalAmount));
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _paidController.addListener(_calculateChange);
  }

  void _calculateChange() {
    final paidDouble = double.tryParse(_paidController.text) ?? 0.0;
    final paidCents = MoneyFormatter.toCents(paidDouble);
    setState(() {
      _change = paidCents - widget.totalAmount;
    });
  }

  @override
  void dispose() {
    _paidController.removeListener(_calculateChange);
    _paidController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // [Refactored]: التحقق عبر الـ Enum
      if (_selectedMethod == PaymentMethod.cash && _change < 0) return; 

      setState(() => _isProcessing = true);

      Navigator.pop(context, {
        'method': _selectedMethod, // 🪄 [Refactored]: إرجاع كائن Enum الآن وليس String!
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDelivery = widget.orderType == OrderType.delivery;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.all(0),
        title: _DialogHeader(onClose: () => Navigator.pop(context)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TotalAmountDisplay(totalAmount: widget.totalAmount),
                  const SizedBox(height: 24),

                  if (isDelivery) ...[
                    _DeliveryDetailsForm(
                      nameController: _nameController,
                      phoneController: _phoneController,
                      addressController: _addressController,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 🪄 تمرير الكائن بدلاً من النصوص
                  _PaymentMethodSelector(
                    selectedMethod: _selectedMethod,
                    onMethodChanged: (val) {
                      setState(() {
                        _selectedMethod = val;
                        if (val != PaymentMethod.cash) {
                          _paidController.text = MoneyFormatter.format(widget.totalAmount);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // 🪄 التحقق عبر الكائن
                  if (_selectedMethod == PaymentMethod.cash)
                    _CashPaymentSection(
                      paidController: _paidController,
                      totalAmount: widget.totalAmount,
                      change: _change,
                    ),
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          _DialogActions(
            isProcessing: _isProcessing,
            // 🪄 التحقق عبر الكائن
            canSubmit: !(_selectedMethod == PaymentMethod.cash && _change < 0),
            onSubmit: _submit,
            onCancel: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets)
// ==========================================

class _DialogHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _DialogHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.teal.shade100, shape: BoxShape.circle),
                child: Icon(Icons.point_of_sale_rounded, color: Colors.teal.shade800, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('إتمام عملية الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: onClose,
            tooltip: 'إلغاء',
          ),
        ],
      ),
    );
  }
}

class _TotalAmountDisplay extends StatelessWidget {
  final int totalAmount;
  const _TotalAmountDisplay({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade600, Colors.teal.shade800]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('الإجمالي المطلوب:', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600)),
          Text('${MoneyFormatter.format(totalAmount)} ج.م', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

class _DeliveryDetailsForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const _DeliveryDetailsForm({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text('بيانات التوصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade900)),
            ],
          ),
          const Divider(height: 24),
          TextFormField(
            controller: nameController,
            decoration: _inputStyle('اسم العميل', Icons.person_outline),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputStyle('رقم الهاتف *', Icons.phone_outlined),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'هذا الحقل مطلوب للتوصيل' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressController,
            maxLines: 2,
            decoration: _inputStyle('العنوان بالتفصيل *', Icons.location_on_outlined),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'هذا الحقل مطلوب للتوصيل' : null,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selectedMethod; // 🪄 أصبح يستقبل Enum
  final ValueChanged<PaymentMethod> onMethodChanged; // 🪄 أصبح يرجع Enum

  const _PaymentMethodSelector({required this.selectedMethod, required this.onMethodChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          // 🪄 توليد الأزرار بناءً على قيم الـ Enum بشكل آلي
          children: PaymentMethod.values.map((method) {
            final isSelected = selectedMethod == method;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => onMethodChanged(method),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.teal : Colors.grey.shade300),
                      boxShadow: isSelected ? [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))] : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      method.toDisplayName(), 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CashPaymentSection extends StatelessWidget {
  final TextEditingController paidController;
  final int totalAmount;
  final int change;

  const _CashPaymentSection({
    required this.paidController,
    required this.totalAmount,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: paidController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
          decoration: InputDecoration(
            labelText: 'المبلغ المستلم من العميل',
            labelStyle: const TextStyle(fontSize: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: const BorderRadius.horizontal(right: Radius.circular(10))),
              child: const Icon(Icons.money_rounded, color: Colors.teal),
            ),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return 'يرجى إدخال المبلغ المستلم';
            final amountDouble = double.tryParse(val);
            if (amountDouble == null) return 'رقم غير صحيح';
            if (MoneyFormatter.toCents(amountDouble) < totalAmount) return 'المبلغ المدفوع أقل من الفاتورة';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: change >= 0 ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: change >= 0 ? Colors.green.shade300 : Colors.red.shade300, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الباقي للعميل:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: change >= 0 ? Colors.green.shade800 : Colors.red.shade800)),
              Text(
                '${change >= 0 ? MoneyFormatter.format(change) : "0.00"} ج.م',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: change >= 0 ? Colors.green.shade700 : Colors.red.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogActions extends StatelessWidget {
  final bool isProcessing;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _DialogActions({
    required this.isProcessing,
    required this.canSubmit,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextButton(
            onPressed: isProcessing ? null : onCancel,
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: isProcessing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.check_circle_outline, size: 28),
            label: Text(
              isProcessing ? 'جاري المعالجة...' : 'تأكيد ودفع',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: isProcessing || !canSubmit ? null : onSubmit,
          ),
        ),
      ],
    );
  }
}