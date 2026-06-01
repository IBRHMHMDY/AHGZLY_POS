import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftStatusHeader extends StatelessWidget {
  final ShiftEntity shift;
  const ShiftStatusHeader({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.access_time_filled_rounded,
            size: 70,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'الوردية نشطة وتعمل الآن',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'وقت الفتح: ${DateFormat('yyyy-MM-dd hh:mm a').format(shift.startTime)}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'العهدة الافتتاحية: ${MoneyFormatter.format(shift.startingCash)} ج.م',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}