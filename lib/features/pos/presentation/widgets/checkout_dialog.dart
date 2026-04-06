import 'package:flutter/material.dart';

class CheckoutDialog extends StatefulWidget {
  final double totalAmount;
  final String orderType;

  const CheckoutDialog({super.key, required this.totalAmount, required this.orderType});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedMethod = 'كاش';
  late TextEditingController _paidController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  double _change = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paidController = TextEditingController(text: widget.totalAmount.toStringAsFixed(2));
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _paidController.addListener(_calculateChange);
  }

  void _calculateChange() {
    final paid = double.tryParse(_paidController.text) ?? 0.0;
    setState(() {
      _change = paid - widget.totalAmount;
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
      if (_selectedMethod == 'كاش' && _change < 0) {
        // منع الدفع إذا كان المبلغ المدفوع أقل من المطلوب
        return;
      }
      
      setState(() => _isProcessing = true);
      
      Navigator.pop(context, {
        'method': _selectedMethod,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDelivery = widget.orderType == 'دليفري';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.point_of_sale, color: Colors.teal.shade700, size: 28),
            const SizedBox(width: 8),
            const Text('إتمام عملية الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 500, // تثبيت العرض للشاشات الكبيرة
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50, 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي المطلوب:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${widget.totalAmount.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (isDelivery) ...[
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('بيانات العميل (التوصيل)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _nameController, 
                      decoration: InputDecoration(labelText: 'اسم العميل', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController, 
                      keyboardType: TextInputType.phone, 
                      decoration: InputDecoration(labelText: 'رقم الهاتف *', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'مطلوب للتوصيل' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController, 
                      maxLines: 2, 
                      decoration: InputDecoration(labelText: 'العنوان بالتفصيل *', prefixIcon: const Icon(Icons.location_on), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'مطلوب للتوصيل' : null,
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  DropdownButtonFormField<String>(
                    value: _selectedMethod,
                    decoration: InputDecoration(
                      labelText: 'طريقة الدفع', 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.payment),
                    ),
                    items: ['كاش', 'فيزا', 'InstaPay'].map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 18)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() { 
                          _selectedMethod = val; 
                          if (val != 'كاش') {
                            _paidController.text = widget.totalAmount.toStringAsFixed(2); 
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  if (_selectedMethod == 'كاش') ...[
                    TextFormField(
                      controller: _paidController, 
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'المبلغ المستلم من العميل', 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), 
                        prefixIcon: const Icon(Icons.money, color: Colors.green),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'أدخل المبلغ';
                        final amount = double.tryParse(val);
                        if (amount == null) return 'رقم غير صحيح';
                        if (amount < widget.totalAmount) return 'المبلغ أقل من الفاتورة';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _change >= 0 ? Colors.green.shade50 : Colors.red.shade50, 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _change >= 0 ? Colors.green.shade200 : Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الباقي للعميل:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            '${_change >= 0 ? _change.toStringAsFixed(2) : "0.00"} ج.م', 
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _change >= 0 ? Colors.green.shade700 : Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : () => Navigator.pop(context), 
            child: const Text('إلغاء', style: TextStyle(color: Colors.red, fontSize: 18)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, 
              foregroundColor: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: _isProcessing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.print),
            label: const Text('تأكيد وطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: (_isProcessing || (_selectedMethod == 'كاش' && _change < 0)) ? null : _submit,
          ),
        ],
      ),
    );
  }
}