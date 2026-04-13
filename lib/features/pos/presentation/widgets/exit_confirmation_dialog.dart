// مسار الملف: lib/features/pos/presentation/widgets/exit_confirmation_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ExitConfirmationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.power_settings_new, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text(
            'إغلاق النظام',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        'هل أنت متأكد من أنك تريد إغلاق البرنامج بالكامل؟',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'إلغاء',
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.exit_to_app),
          label: const Text('تأكيد الإغلاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: () => exit(0), 
        ),
      ],
    );
  }
}