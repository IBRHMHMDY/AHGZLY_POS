import 'package:flutter/material.dart';

class CloseShiftDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const CloseShiftDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text('تأكيد إغلاق الوردية', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
      content: const Text(
        'هل أنت متأكد من إغلاق الوردية وتصفير العدادات لليوم الجديد؟\nسيتم طباعة التقرير النهائي (Z-Report) تلقائياً قبل التصفير.', 
        style: TextStyle(fontSize: 16, height: 1.5)
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.lock_clock),
          label: const Text('تأكيد الإغلاق والطباعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: () {
            Navigator.pop(context); // إغلاق النافذة أولاً
            onConfirm(); // تنفيذ دالة الإغلاق والطباعة
          },
        ),
      ],
    );
  }
}