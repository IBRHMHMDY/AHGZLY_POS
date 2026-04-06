import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// استيراد مسارات الحقن والطباعة والإعدادات
import '../../../../core/routing/app_router.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/printer_service.dart';
import '../../../settings/domain/usecases/get_settings_usecase.dart';
import '../../../pos/presentation/widgets/receipt_widgets.dart';

import '../../domain/entities/shift.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';
import '../bloc/shift_state.dart';
import '../widgets/close_shift_dialog.dart';

class ShiftReportScreen extends StatefulWidget {
  const ShiftReportScreen({super.key});

  @override
  State<ShiftReportScreen> createState() => _ShiftReportScreenState();
}

class _ShiftReportScreenState extends State<ShiftReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShiftBloc>().add(CheckActiveShiftEvent());
  }

  // تم تعديل الباراميتر هنا ليستقبل كائن Shift كاملاً
  void _onCloseShiftPressed(Shift shift) async {
    final actualCash = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CloseShiftDialog(expectedCash: shift.expectedCash), // التمرير صحيح الآن
    );

    if (actualCash != null && mounted) {
      context.read<ShiftBloc>().add(
        CloseShiftSubmittedEvent(shiftId: shift.id, actualCash: actualCash) // استخراج الـ ID من الكائن
      );
    }
  }

  // --- دالة الطباعة الفعلية ---
  void _printZReport(Shift shift) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تجهيز الطباعة...')),
    );

    // 1. جلب اسم المطعم من الإعدادات
    final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
    String restaurantName = 'مطعم احجزلي';
    settingsResult.fold(
      (failure) {},
      (settings) => restaurantName = settings.restaurantName,
    );

    // 2. تجهيز الفاتورة وإرسالها لخدمة الطباعة
    final printerService = sl<PrinterService>();
    final success = await printerService.printReceiptUsb(
      receiptWidget: ZReportReceiptWidget(
        shift: shift,
        restaurantName: restaurantName,
      ),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال أمر الطباعة بنجاح'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في الطباعة، تأكد من اتصال الطابعة واسمها في الإعدادات'), 
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الوردية الحالية / Z-Report'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.posPath),
        ),
      ),
      body: BlocConsumer<ShiftBloc, ShiftState>(
        listener: (context, state) {
          if (state is ShiftError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }else if (state is ShiftClosedSuccess) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إغلاق الوردية بنجاح، جاري الطباعة التلقائية...'), 
                backgroundColor: Colors.green
              ),
            );
            // استدعاء دالة الطباعة الموجودة بالفعل في ملفك
            _printZReport(state.closedShift); 
          }
        },
        builder: (context, state) {
          if (state is ShiftLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is NoActiveShiftState) {
            return const Center(child: Text('لا توجد وردية نشطة حالياً.', style: TextStyle(fontSize: 18)));
          }

          if (state is ActiveShiftLoaded) {
            final shift = state.shift;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_filled, size: 100, color: Colors.green),
                  const SizedBox(height: 24),
                  const Text('الوردية نشطة وتعمل الآن', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('وقت الفتح: ${DateFormat('yyyy-MM-dd hh:mm a').format(shift.startTime)}'),
                  Text('العهدة الافتتاحية: ${shift.startingCash.toStringAsFixed(2)} EGP'),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    // تم تعديل الاستدعاء هنا لتمرير كائن الـ shift بدلاً من الـ ID فقط
                    onPressed: () => _onCloseShiftPressed(shift),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('إنهاء وإغلاق الوردية (Z-Report)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
            );
          }

          if (state is ShiftClosedSuccess) {
            return _buildZReportSummary(state.closedShift);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildZReportSummary(Shift shift) {
    final isShortage = shift.shortageOrOverage < 0;
    final isOverage = shift.shortageOrOverage > 0;
    final diffColor = isShortage ? Colors.red : (isOverage ? Colors.green : Colors.grey.shade800);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('ملخص الوردية (Z-Report)', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(height: 32, thickness: 2),
              
              _buildReportRow('وقت الفتح:', DateFormat('yyyy-MM-dd hh:mm a').format(shift.startTime)),
              if (shift.endTime != null)
                _buildReportRow('وقت الإغلاق:', DateFormat('yyyy-MM-dd hh:mm a').format(shift.endTime!)),
              
              const Divider(height: 32),
              _buildReportRow('إجمالي عدد الطلبات:', '${shift.totalOrders} طلب'),
              _buildReportRow('العهدة الافتتاحية:', '${shift.startingCash.toStringAsFixed(2)} EGP'),
              _buildReportRow('إجمالي المبيعات:', '${shift.totalSales.toStringAsFixed(2)} EGP'),
              _buildReportRow('المبيعات الكاش:', '${shift.totalCash.toStringAsFixed(2)} EGP'),
              _buildReportRow('المبيعات الفيزا:', '${shift.totalVisa.toStringAsFixed(2)} EGP'),
              _buildReportRow('المبيعات إنستا باي:', '${shift.totalInstapay.toStringAsFixed(2)} EGP'),
              _buildReportRow('إجمالي المصروفات:', '${shift.totalExpenses.toStringAsFixed(2)} EGP', color: Colors.red),
              
              const Divider(height: 32, thickness: 2),
              _buildReportRow('النقدية المتوقعة في الدرج:', '${shift.expectedCash.toStringAsFixed(2)} EGP', isBold: true),
              _buildReportRow('النقدية الفعلية (التي تم عدها):', '${shift.actualCash.toStringAsFixed(2)} EGP', isBold: true, color: Colors.blueAccent),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                color: diffColor.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isShortage ? 'عجز في الدرج:' : (isOverage ? 'زيادة في الدرج:' : 'مطابقة تامة:'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: diffColor)),
                    Text('${shift.shortageOrOverage.abs().toStringAsFixed(2)} EGP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: diffColor)),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRouter.loginPath), 
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('خروج'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _printZReport(shift),
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة Z-Report'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}