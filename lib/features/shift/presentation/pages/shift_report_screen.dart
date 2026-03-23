import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_event.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';

class ShiftReportScreen extends StatelessWidget {
  const ShiftReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الوردية (Z-Report)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<ShiftBloc, ShiftState>(
          listener: (context, state) {
            if (state is ShiftClosedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              // إعادة تحميل الأرقام (ستكون أصفاراً بعد الإغلاق)
              context.read<ShiftBloc>().add(LoadZReportEvent());
            } else if (state is ShiftError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is ShiftLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ZReportLoaded) {
              final report = state.report;
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: Colors.teal.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Text('إجمالي المبيعات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('${report.totalSales} ج.م', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.teal)),
                            const SizedBox(height: 8),
                            Text('عدد الطلبات: ${report.totalOrders}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('مبيعات الكاش', report.totalCash, Icons.money, Colors.green)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('مبيعات الفيزا', report.totalVisa, Icons.credit_card, Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('InstaPay', report.totalInstaPay, Icons.phone_android, Colors.purple)),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.lock_clock),
                      label: const Text('إغلاق الوردية (تقفيل الصندوق)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      onPressed: report.totalOrders == 0
                          ? null
                          : () {
                              _showConfirmationDialog(context, report);
                            },
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('جاري جلب البيانات...'));
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$amount ج.م', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, report) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد إغلاق الوردية', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد من رغبتك في إغلاق الوردية؟ سيتم تصفير العدادات لبدء وردية جديدة ولن تتمكن من التراجع عن هذه الخطوة.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ShiftBloc>().add(CloseCurrentShiftEvent(report));
              },
              child: const Text('نعم، قم بالإغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}