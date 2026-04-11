// lib/features/shift/presentation/pages/shift_report_screen.dart

import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/printer_service.dart';
import '../../../settings/domain/usecases/get_settings_usecase.dart';
import '../../../pos/presentation/widgets/receipt_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

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

  // 1. دالة إغلاق الوردية (التي تفتح نافذة إدخال المبلغ)
  void _onCloseShiftPressed(Shift shift) async {
    final actualCash = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CloseShiftDialog(expectedCash: shift.expectedCash),
    );

    if (actualCash != null && mounted) {
      context.read<ShiftBloc>().add(
        CloseShiftSubmittedEvent(shiftId: shift.id, actualCash: actualCash)
      );
    }
  }

  // 2. دالة طباعة التقرير فقط (بدون إغلاق - X-Report)
  void _printReportOnly(Shift shift) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري طباعة ملخص المبيعات (X-Report)...'), backgroundColor: Colors.orange),
    );

    final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
    String restaurantName = 'مطعم احجزلي';
    String printerName = 'EPSON Printer'; // ✅ إضافة المتغير
    settingsResult.fold(
      (failure) {},
      (settings) {
        restaurantName = settings.restaurantName;
        printerName = settings.printerName; // ✅ استخراج اسم الطابعة
      },
    );

    final authState = context.read<AuthBloc>().state;
    final cashierName = (authState is AuthAuthenticated) ? authState.user.name : 'غير معروف';

    final success = await sl<PrinterService>().printReceiptUsb(
      receiptWidget: ZReportReceiptWidget(
        shift: shift,
        restaurantName: restaurantName,
        cashierName: cashierName,
        isXReport: true, 
      ),
      printerName: printerName, // ✅ تمرير الطابعة
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت الطباعة بنجاح!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل الطباعة، يرجى فحص الطابعة'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 3. دالة ما بعد الإغلاق: (طباعة Z-Report + طرد إجباري)
  void _processClosePrintAndExit(Shift shift) async {
    final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
    String restaurantName = 'مطعم احجزلي';
    String printerName = 'EPSON Printer'; // ✅ إضافة المتغير
    settingsResult.fold(
      (failure) {},
      (settings) {
        restaurantName = settings.restaurantName;
        printerName = settings.printerName; // ✅ استخراج اسم الطابعة
      },
    );

    final authState = context.read<AuthBloc>().state;
    final cashierName = (authState is AuthAuthenticated) ? authState.user.name : 'غير معروف';

    await sl<PrinterService>().printReceiptUsb(
      receiptWidget: ZReportReceiptWidget(
        shift: shift,
        restaurantName: restaurantName,
        cashierName: cashierName,
      ),
      printerName: printerName, // ✅ تمرير الطابعة
    );

    if (mounted) {
      context.read<AuthBloc>().add(LogoutEvent());
      context.go('/'); // طرد لشاشة تسجيل الدخول
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة الوردية'),
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
          }
          // 🪄 حماية النظام: عند الإغلاق الناجح، يتم استدعاء دالة الطرد والطباعة التلقائية
          else if (state is ShiftClosedSuccess) {
            _processClosePrintAndExit(state.closedShift);
          }
        },
        builder: (context, state) {
          if (state is ShiftLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is NoActiveShiftState) {
            return const Center(child: Text('لا توجد وردية نشطة حالياً.', style: TextStyle(fontSize: 18)));
          }

          // 🪄 الدمج المطلوب: عرض الواجهة السابقة (الساعة الخضراء) وتحتها الملخص والأزرار
          if (state is ActiveShiftLoaded) {
            return _buildCombinedActiveShiftView(state.shift);
          }

          // شاشة التحميل اللحظية أثناء الإغلاق والطباعة وقبل الطرد
          if (state is ShiftClosedSuccess) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 24),
                  Text('تم الإغلاق.. جاري الطباعة وتسجيل الخروج', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // 🪄 الواجهة المدمجة (الساعة الخضراء + الملخص + الأزرار)
  Widget _buildCombinedActiveShiftView(Shift shift) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Center(
        child: Column(
          children: [
            // === 1. الجزء العلوي: الواجهة السابقة (الساعة الخضراء) ===
            const Icon(Icons.access_time_filled, size: 90, color: Colors.green),
            const SizedBox(height: 16),
            const Text('الوردية نشطة وتعمل الآن', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('وقت الفتح: ${DateFormat('yyyy-MM-dd hh:mm a').format(shift.startTime)}', style: const TextStyle(fontSize: 16)),
            Text('العهدة الافتتاحية: ${MoneyFormatter.format(shift.startingCash)} ج.م', style: const TextStyle(fontSize: 16)),
            
            const SizedBox(height: 40),

            // === 2. الجزء السفلي: شاشة الملخص والأزرار ===
            Container(
              width: 550, 
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
                  const Text('ملخص المبيعات (X-Report)', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(height: 32, thickness: 2),
                  
                  _buildReportRow('إجمالي عدد الطلبات:', '${shift.totalOrders} طلب'),
                  _buildReportRow('إجمالي المبيعات:', '${MoneyFormatter.format(shift.totalSales)} ج.م'),
                  _buildReportRow('المبيعات الكاش:', '${MoneyFormatter.format(shift.totalCash)} ج.م'),
                  _buildReportRow('المبيعات الفيزا:', '${MoneyFormatter.format(shift.totalVisa)} ج.م'),
                  _buildReportRow('المبيعات إنستا باي:', '${MoneyFormatter.format(shift.totalInstapay)} ج.م'),
                  _buildReportRow('إجمالي المرتجعات (${shift.refundedOrdersCount} طلب):', '${MoneyFormatter.format(shift.totalRefunds)} ج.م', color: Colors.red),
                  _buildReportRow('إجمالي المصروفات:', '${MoneyFormatter.format(shift.totalExpenses)} ج.م', color: Colors.red),
                  const Divider(height: 32, thickness: 2),
                  _buildReportRow('النقدية المتوقعة في الدرج:', '${MoneyFormatter.format(shift.expectedCash)} ج.م', isBold: true, color: Colors.blueAccent),
                  
                  const SizedBox(height: 40),
                  
                  // === 3. الأزرار الحالية المطلوبة ===
                  Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.go(AppRouter.posPath),
                        icon: const Icon(Icons.storefront),
                        label: const Text('عودة للكاشير'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _printReportOnly(shift),
                        icon: const Icon(Icons.print),
                        label: const Text('طباعة التقرير'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, 
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _onCloseShiftPressed(shift),
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('إغلاق الوردية'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent, 
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
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