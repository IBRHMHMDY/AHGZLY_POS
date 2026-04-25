import 'package:flutter/material.dart';

// ==========================================
// 1. ترويسة النوافذ المنبثقة الموحدة
// ==========================================
class PosDialogHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const PosDialogHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.teal.shade100, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.teal.shade800, size: 28),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. أزرار الإجراءات للنوافذ الموحدة
// ==========================================
class PosDialogActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitText;

  const PosDialogActions({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    this.submitText = 'حفظ البيانات',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: const Text('إلغاء', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
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
            label: Text(submitText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}