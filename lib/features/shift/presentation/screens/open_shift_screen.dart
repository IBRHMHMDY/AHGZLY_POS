import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';
import '../bloc/shift_state.dart';

class OpenShiftScreen extends StatefulWidget {
  final int cashierId;
  const OpenShiftScreen({super.key, required this.cashierId});

  @override
  State<OpenShiftScreen> createState() => _OpenShiftScreenState();
}

class _OpenShiftScreenState extends State<OpenShiftScreen> {
  final TextEditingController _cashController = TextEditingController();

  void _submit() {
    final cashText = _cashController.text.trim();
    if (cashText.isEmpty) return;

    final startingCash = MoneyFormatter.toCents(double.parse(cashText));
    if (startingCash < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح للعهدة'), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<ShiftBloc>().add(OpenShiftSubmittedEvent(startingCash: startingCash, cashierId: widget.cashierId));
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50, // 🪄 توحيد الخلفية مع هوية التطبيق
      appBar: AppBar(
        title: const Text('فتح وردية جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            tooltip: 'تسجيل الخروج',
            onPressed: () => context.go(AppRouter.loginPath),
          ),
        ],
      ),
      body: BlocConsumer<ShiftBloc, ShiftState>(
        listener: (context, state) {
          if (state is ShiftOpenedSuccess) {
            context.go(AppRouter.posPath);
          } else if (state is ShiftError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          return Center(
            child: _OpenShiftForm(
              cashController: _cashController,
              isLoading: state is ShiftLoading,
              onSubmit: _submit,
            ),
          );
        },
      ),
    );
  }
}

// 🪄 استخراج الفورم لتنظيف دالة الـ Build
class _OpenShiftForm extends StatelessWidget {
  final TextEditingController cashController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _OpenShiftForm({required this.cashController, required this.isLoading, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      padding: const EdgeInsets.all(40.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.point_of_sale_rounded, size: 80, color: Colors.teal),
          ),
          const SizedBox(height: 24),
          const Text('العهدة الافتتاحية للدرج', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('الرجاء إدخال النقدية الموجودة في الدرج حالياً لفتح الوردية', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 32),
          TextField(
            controller: cashController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
            decoration: InputDecoration(
              prefixText: 'ج.م ',
              prefixStyle: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.teal, width: 2)),
              hintText: '0.00',
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              icon: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.lock_open_rounded, size: 28),
              label: Text(isLoading ? 'جاري الفتح...' : 'فتح الدرج وبدء البيع', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}