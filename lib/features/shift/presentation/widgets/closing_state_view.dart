import 'package:flutter/material.dart';

class ClosingStateView extends StatelessWidget {
  const ClosingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.redAccent),
          SizedBox(height: 24),
          Text(
            'تم إغلاق الوردية.. جاري طباعة (Z-Report) وتسجيل الخروج',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}