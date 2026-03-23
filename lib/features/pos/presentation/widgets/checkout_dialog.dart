import 'package:flutter/material.dart';

class CheckoutDialog extends StatelessWidget {
  final double totalAmount;

  const CheckoutDialog({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إتمام الدفع', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('الإجمالي المطلوب:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              '$totalAmount ج.م',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 24),
            const Text('اختر طريقة الدفع لتأكيد الطلب:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.money),
                  label: const Text('كاش', style: TextStyle(fontSize: 16)),
                  onPressed: () => Navigator.pop(context, 'كاش'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.credit_card),
                  label: const Text('فيزا', style: TextStyle(fontSize: 16)),
                  onPressed: () => Navigator.pop(context, 'فيزا'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.phone_android),
                  label: const Text('InstaPay', style: TextStyle(fontSize: 16)),
                  onPressed: () => Navigator.pop(context, 'InstaPay'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}