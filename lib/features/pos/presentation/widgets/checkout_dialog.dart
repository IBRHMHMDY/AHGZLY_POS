import 'package:flutter/material.dart';

class CheckoutDialog extends StatefulWidget {
  final double totalAmount;
  final String orderType;

  const CheckoutDialog({
    super.key,
    required this.totalAmount,
    required this.orderType,
  });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  String _selectedMethod = 'كاش';
  late TextEditingController _paidController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  double _change = 0.0;

  @override
  void initState() {
    super.initState();
    _paidController = TextEditingController(text: widget.totalAmount.toString());
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
    _paidController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDelivery = widget.orderType == 'دليفري';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إتمام الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDelivery) ...[
                const Text('بيانات العميل (دليفري)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const Divider(),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم العميل', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'العنوان بالتفصيل', prefixIcon: Icon(Icons.location_on)),
                ),
                const SizedBox(height: 20),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المطلوب:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${widget.totalAmount} ج.م', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: const InputDecoration(labelText: 'طريقة الدفع', border: OutlineInputBorder()),
                items: ['كاش', 'فيزا', 'InstaPay']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMethod = val;
                      if (val != 'كاش') {
                        _paidController.text = widget.totalAmount.toString();
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              if (_selectedMethod == 'كاش') ...[
                TextFormField(
                  controller: _paidController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(labelText: 'المبلغ المدفوع (من العميل)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.money)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _change >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المتبقي (باقي للعميل):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${_change >= 0 ? _change.toStringAsFixed(2) : "مبلغ غير كافٍ"} ج.م', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _change >= 0 ? Colors.green.shade700 : Colors.red)),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: Colors.red))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            onPressed: (_selectedMethod == 'كاش' && _change < 0) ? null : () {
              Navigator.pop(context, {
                'method': _selectedMethod,
                'name': _nameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'address': _addressController.text.trim(),
              });
            },
            child: const Text('تأكيد وطباعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}