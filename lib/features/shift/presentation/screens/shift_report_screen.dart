import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/shift/presentation/widgets/active_shift_view.dart';
import 'package:ahgzly_pos/features/shift/presentation/widgets/closing_state_view.dart';
import 'package:ahgzly_pos/features/shift/presentation/widgets/shift_report_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';

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

// 1. [SRP]: دالة مساعدة مسؤولة حصرياً عن إظهار الإشعارات لتقليل التكرار
  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // 2. [DRY & Clean Architecture]: محرك طباعة موحد يعالج كلا التقريرين (X و Z)
  Future<void> _executePrintTask(ShiftEntity shift, {required bool isXReport, VoidCallback? onComplete}) async {
    if (isXReport) _showSnack('جاري الطباعة...', Colors.teal);

    // أ. جلب الإعدادات بأقل عدد من الأسطر
    final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
    final settings = settingsResult.fold((l) => null, (r) => r);

    if (settings == null || settings.printerName.isEmpty) {
      return _showSnack('يرجى تحديد طابعة صالحة من الإعدادات أولاً!', Colors.orange);
    }

    // ب. جلب اسم الكاشير 
    final authState = context.read<AuthBloc>().state;
    final cashierName = authState is AuthAuthenticated ? authState.user.name : 'غير معروف';

    // ج. تنفيذ الطباعة
    final success = await sl<PrinterService>().printReceiptUsb(
      receiptWidget: ZReportReceiptWidget(
        shift: shift,
        restaurantName: settings.restaurantName,
        cashierName: cashierName,
        isXReport: isXReport,
      ),
      printerName: settings.printerName,
    );

    // د. معالجة النتائج وتوجيه المستخدم
    if (isXReport) {
      _showSnack(
        success ? 'تمت الطباعة بنجاح!' : 'فشل الطباعة، تفقد كابل الطابعة: ${settings.printerName}',
        success ? Colors.green : Colors.red,
      );
    }

    // تنفيذ أي حدث إضافي (مثل تسجيل الخروج) إن وُجد
    onComplete?.call();
  }

  // 3. [Clean Code]: دوال الاستدعاء أصبحت عبارة عن سطر واحد فقط! (One-liners)
  void _printReportOnly(ShiftEntity shift) => _executePrintTask(shift, isXReport: true);

  void _processClosePrintAndExit(ShiftEntity shift) {
    _executePrintTask(shift, isXReport: false, onComplete: () {
      if (mounted) {
        context.read<AuthBloc>().add(LogoutEvent());
        context.go(AppRoutes.login);
      }
    });
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
          if (state is ShiftLoading) return const ShiftReportShimmer();
          if (state is NoActiveShiftState) {
            return const Center(child: Text('لا توجد وردية نشطة حالياً.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)));
          }
          if (state is ActiveShiftLoaded) {
            return ActiveShiftView(shift: state.shift, onPrintReport: () => _printReportOnly(state.shift), onCloseShift: () => _onCloseShiftPressed(state.shift));
          }
          if (state is ShiftClosedSuccess) return const ClosingStateView();
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
