import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/core/common/widgets/custom_shimmer.dart'; 
import 'package:ahgzly_pos/core/utils/money_formatter.dart';

import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_state.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:ahgzly_pos/features/pos/presentation/widgets/receipt_widgets.dart';

import '../../domain/entities/shift_entity.dart';
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

  void _onCloseShiftPressed(ShiftEntity shift) async {
    final actualCash = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CloseShiftDialog(expectedCash: shift.expectedCash),
    );

    if (actualCash != null && mounted) {
      context.read<ShiftBloc>().add(
        CloseShiftSubmittedEvent(shiftId: shift.id, actualCash: actualCash),
      );
    }
  }

  // 🚀 جلب البيانات من الـ Bloc بشكل موحد لتجنب تكرار الكود
  Map<String, String> _getPrinterAndAuthInfo() {
    String rName = 'مطعم احجزلي';
    String pName = 'EPSON Printer';

    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      rName = settingsState.settings.restaurantName;
      pName = settingsState.settings.printerName;
    }

    final authState = context.read<AuthBloc>().state;
    final cashierName = (authState is AuthAuthenticated) ? authState.user.name : 'غير معروف';

    return {'restaurantName': rName, 'printerName': pName, 'cashierName': cashierName};
  }

  void _printReportOnly(ShiftEntity shift) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري طباعة ملخص المبيعات (X-Report)...'), backgroundColor: Colors.teal));

    final info = _getPrinterAndAuthInfo();

    final success = await sl<PrinterService>().printReceiptUsb(
      receiptWidget: ZReportReceiptWidget(shift: shift, restaurantName: info['restaurantName']!, cashierName: info['cashierName']!, isXReport: true),
      printerName: info['printerName']!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'تمت الطباعة بنجاح!' : 'فشل الطباعة، يرجى فحص الطابعة'), backgroundColor: success ? Colors.green : Colors.red),
      );
    }
  }

  // 🚀 [FIXED]: إزالة UseCase وقراءة البيانات مباشرة من الـ State (Clean Architecture)
  void _processClosePrintAndExit(ShiftEntity shift) async {
    final info = _getPrinterAndAuthInfo();

    await sl<PrinterService>().printReceiptUsb(
      receiptWidget: ZReportReceiptWidget(
        shift: shift,
        restaurantName: info['restaurantName']!,
        cashierName: info['cashierName']!,
      ),
      printerName: info['printerName']!,
    );

    if (mounted) {
      context.read<AuthBloc>().add(LogoutEvent());
      context.go(AppRoutes.login); // التوجيه الصحيح عبر الـ Router
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('حالة الوردية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.pos),
        ),
      ),
      body: BlocConsumer<ShiftBloc, ShiftState>(
        listener: (context, state) {
          if (state is ShiftError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          } else if (state is ShiftClosedSuccess) {
            _processClosePrintAndExit(state.closedShift);
          }
        },
        builder: (context, state) {
          if (state is ShiftLoading) return const _ShiftReportShimmer();
          if (state is NoActiveShiftState) {
            return const Center(child: Text('لا توجد وردية نشطة حالياً.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)));
          }
          if (state is ActiveShiftLoaded) {
            return _ActiveShiftView(shift: state.shift, onPrintReport: () => _printReportOnly(state.shift), onCloseShift: () => _onCloseShiftPressed(state.shift));
          }
          if (state is ShiftClosedSuccess) return const _ClosingStateView();
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ... احتفظ بباقي المكونات الفرعية (_ActiveShiftView, _FinancialSummaryCard, إلخ) كما كتبتها تماماً بدون تغيير

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets)
// ==========================================

class _ActiveShiftView extends StatelessWidget {
  final ShiftEntity shift;
  final VoidCallback onPrintReport;
  final VoidCallback onCloseShift;

  const _ActiveShiftView({
    required this.shift,
    required this.onPrintReport,
    required this.onCloseShift,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            _ShiftStatusHeader(shift: shift),
            const SizedBox(height: 32),
            _FinancialSummaryCard(shift: shift),
            const SizedBox(height: 32),
            _ActionButtonsRow(
              onPrintReport: onPrintReport,
              onCloseShift: onCloseShift,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftStatusHeader extends StatelessWidget {
  final ShiftEntity shift;
  const _ShiftStatusHeader({required this.shift});

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

class _FinancialSummaryCard extends StatelessWidget {
  final ShiftEntity shift;
  const _FinancialSummaryCard({required this.shift});

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

class _ActionButtonsRow extends StatelessWidget {
  final VoidCallback onPrintReport;
  final VoidCallback onCloseShift;

  const _ActionButtonsRow({
    required this.onPrintReport,
    required this.onCloseShift,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.pos),
          icon: const Icon(Icons.storefront),
          label: const Text(
            'عودة للكاشير',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.teal,
            side: const BorderSide(color: Colors.teal, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onPrintReport,
          icon: const Icon(Icons.print),
          label: const Text(
            'طباعة التقرير',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onCloseShift,
          icon: const Icon(Icons.lock_outline),
          label: const Text(
            'إغلاق الوردية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClosingStateView extends StatelessWidget {
  const _ClosingStateView();

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

class _ShiftReportShimmer extends StatelessWidget {
  const _ShiftReportShimmer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomShimmer.circular(width: 100, height: 100),
          const SizedBox(height: 24),
          CustomShimmer.rectangular(
            width: 300,
            height: 24,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 40),
          CustomShimmer.rectangular(
            width: 600,
            height: 400,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
