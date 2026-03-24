import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/di/injection_container.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/receipt_widgets.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_event.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';

class ShiftReportScreen extends StatefulWidget {
  const ShiftReportScreen({super.key});

  @override
  State<ShiftReportScreen> createState() => _ShiftReportScreenState();
}

class _ShiftReportScreenState extends State<ShiftReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShiftBloc>().add(LoadZReportEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الوردية (Z-Report)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<ShiftBloc, ShiftState>(
          listener: (context, state) {
            if (state is ShiftClosedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إغلاق الوردية بنجاح!'), backgroundColor: Colors.green),
              );
              context.go('/pos');
            } else if (state is ShiftError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is ShiftLoading) return const Center(child: CircularProgressIndicator());
            
            if (state is ZReportLoaded) {
              final report = state.report;
              final netCash = report.totalCash - report.totalExpenses; // صافي الكاش في الدرج

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildStatCard('إجمالي المبيعات', report.totalSales, Colors.blue),
                          _buildStatCard('إجمالي عدد الطلبات', report.totalOrders.toDouble(), Colors.grey, isCurrency: false),
                          _buildStatCard('مبيعات الفيزا', report.totalVisa, Colors.orange),
                          _buildStatCard('مبيعات إنستاباي', report.totalInstaPay, Colors.purple),
                          _buildStatCard('مبيعات الكاش (قبل المصروفات)', report.totalCash, Colors.teal),
                          _buildStatCard('المصروفات (خوارج الدرج)', report.totalExpenses, Colors.red),
                        ],
                      ),
                    ),
                    const Divider(thickness: 2),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: netCash >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                        border: Border.all(color: netCash >= 0 ? Colors.green : Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('صافي النقدية بالدرج (كاش - مصروفات):', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(
                            '${netCash.toStringAsFixed(2)} ج.م',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: netCash >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)),
                            icon: const Icon(Icons.print),
                            label: const Text('طباعة التقرير (X-Report)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            onPressed: report.totalOrders == 0 ? null : () async {
                              final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
                              String rName = 'مـطـعـم احـجـزلـي';
                              settingsResult.fold((l) => null, (r) => rName = r.restaurantName);
                              
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري طباعة التقرير...')));
                              await sl<PrinterService>().printReceiptUsb(receiptWidget: ZReportReceiptWidget(report: report, restaurantName: rName));
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)),
                            icon: const Icon(Icons.lock_clock),
                            label: const Text('إغلاق الوردية (Z-Report)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            onPressed: report.totalOrders == 0 ? null : () => _showConfirmationDialog(context, report),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color, {bool isCurrency = true}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: color, width: 6)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              isCurrency ? '${value.toStringAsFixed(2)} ج.م' : value.toInt().toString(),
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, ShiftReport report) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد إغلاق الوردية', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد من إغلاق الوردية وتصفير العدادات لليوم الجديد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                // 1. طباعة التقرير الأخير قبل التصفير
                final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
                String rName = 'مـطـعـم احـجـزلـي';
                settingsResult.fold((l) => null, (r) => rName = r.restaurantName);
                await sl<PrinterService>().printReceiptUsb(receiptWidget: ZReportReceiptWidget(report: report, restaurantName: rName));
                
                // 2. إغلاق الوردية في قاعدة البيانات
                if (context.mounted) {
                  context.read<ShiftBloc>().add(CloseCurrentShiftEvent(report));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('تأكيد الإغلاق والطباعة'),
            ),
          ],
        ),
      ),
    );
  }
}