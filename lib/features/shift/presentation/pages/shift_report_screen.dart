import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/receipt_widgets.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_event.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';
import 'package:ahgzly_pos/features/shift/presentation/widgets/close_shift_dialog.dart';

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

  void _showConfirmationDialog(BuildContext context, ShiftReport report) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CloseShiftDialog(
        onConfirm: () async {
          // 1. طباعة التقرير الأخير قبل التصفير
          final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
          String rName = 'مـطـعـم احـجـزلـي';
          settingsResult.fold((l) => null, (r) => rName = r.restaurantName);
          await sl<PrinterService>().printReceiptUsb(receiptWidget: ZReportReceiptWidget(report: report, restaurantName: rName));
          
          // 2. إغلاق الوردية في قاعدة البيانات
          if (context.mounted) {
            context.read<ShiftBloc>().add(CloseCurrentShiftEvent(report));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.analytics),
            SizedBox(width: 8),
            Text('تقرير الوردية (Z-Report)', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ShiftBloc, ShiftState>(
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

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildStatCard('إجمالي المبيعات', report.totalSales, Colors.blue, Icons.point_of_sale),
                            _buildStatCard('إجمالي عدد الطلبات', report.totalOrders.toDouble(), Colors.grey.shade700, Icons.receipt_long, isCurrency: false),
                            _buildStatCard('مبيعات الفيزا', report.totalVisa, Colors.orange, Icons.credit_card),
                            _buildStatCard('مبيعات إنستاباي', report.totalInstaPay, Colors.purple, Icons.send_to_mobile),
                            _buildStatCard('مبيعات الكاش (قبل المصروفات)', report.totalCash, Colors.teal, Icons.attach_money),
                            _buildStatCard('المصروفات (خوارج الدرج)', report.totalExpenses, Colors.red, Icons.money_off),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // كارت صافي النقدية بالدرج
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: netCash >= 0 ? Colors.green.shade200 : Colors.red.shade200, width: 2),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: netCash >= 0 ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet, color: netCash >= 0 ? Colors.green : Colors.red, size: 32),
                                const SizedBox(width: 12),
                                const Text('صافي النقدية بالدرج (كاش - مصروفات):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                            Text(
                              '${netCash.toStringAsFixed(2)} ج.م',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: netCash >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // أزرار الإجراءات
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700, 
                                foregroundColor: Colors.white, 
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                              ),
                              icon: const Icon(Icons.print, size: 24),
                              label: const Text('طباعة التقرير (X-Report)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700, 
                                foregroundColor: Colors.white, 
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                              ),
                              icon: const Icon(Icons.lock_clock, size: 24),
                              label: const Text('إغلاق الوردية (Z-Report)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              onPressed: report.totalOrders == 0 ? null : () => _showConfirmationDialog(context, report),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color, IconData icon, {bool isCurrency = true}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(right: BorderSide(color: color, width: 6)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    isCurrency ? '${value.toStringAsFixed(2)} ج.م' : value.toInt().toString(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}