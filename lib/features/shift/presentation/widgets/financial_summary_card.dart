import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

class FinancialSummaryCard extends StatelessWidget {
  final ShiftEntity shift;
  const FinancialSummaryCard({super.key, required this.shift});

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'ملخص المبيعات (X-Report)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          _buildRow('إجمالي عدد الطلبات:', '${shift.totalOrders} طلب'),
          _buildRow(
            'إجمالي المبيعات:',
            '${MoneyFormatter.format(shift.totalSales)} ج.م',
          ),
          _buildRow(
            'المبيعات الكاش:',
            '${MoneyFormatter.format(shift.totalCash)} ج.م',
            color: Colors.green.shade700,
          ),
          _buildRow(
            'المبيعات الفيزا:',
            '${MoneyFormatter.format(shift.totalVisa)} ج.م',
            color: Colors.orange.shade700,
          ),
          _buildRow(
            'المبيعات إنستا باي:',
            '${MoneyFormatter.format(shift.totalInstapay)} ج.م',
            color: Colors.purple.shade700,
          ),
          _buildRow(
            'إجمالي المرتجعات (${shift.refundedOrdersCount}):',
            '${MoneyFormatter.format(shift.totalRefunds)} ج.م',
            color: Colors.red,
          ),
          _buildRow(
            'إجمالي المصروفات:',
            '${MoneyFormatter.format(shift.totalExpenses)} ج.م',
            color: Colors.red,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(thickness: 2),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildRow(
              'النقدية المتوقعة في الدرج:',
              '${MoneyFormatter.format(shift.expectedCash)} ج.م',
              isBold: true,
              color: Colors.teal.shade900,
            ),
          ),
        ],
      ),
    );
  }
}