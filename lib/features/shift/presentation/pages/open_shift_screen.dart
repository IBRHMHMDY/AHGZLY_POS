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

    final startingCash = double.tryParse(cashText);
    if (startingCash == null || startingCash < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح للعهدة'), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<ShiftBloc>().add(
      OpenShiftSubmittedEvent(startingCash: startingCash, cashierId: widget.cashierId)
    );
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فتح وردية جديدة'),
        centerTitle: true,
        automaticallyImplyLeading: false, // لا يسمح بالرجوع لشاشة الدخول إلا بتسجيل الخروج
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => context.go(AppRouter.loginPath),
          )
        ],
      ),
      body: BlocConsumer<ShiftBloc, ShiftState>(
        listener: (context, state) {
          if (state is ShiftOpenedSuccess) {
            context.go(AppRouter.posPath);
          } else if (state is ShiftError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.point_of_sale, size: 80, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  const Text('العهدة الافتتاحية للدرج', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('الرجاء إدخال المبلغ الموجود في الدرج قبل بدء البيع', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  
                  TextField(
                    controller: _cashController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      prefixText: 'EGP ',
                      border: OutlineInputBorder(),
                      hintText: '0.00',
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is ShiftLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: state is ShiftLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('فتح الدرج وبدء البيع', style: TextStyle(fontSize: 18)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}