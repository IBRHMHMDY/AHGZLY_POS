import 'dart:io'; // ⬅️ إضافة هامة للتعامل مع أوامر النظام
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final bool isActivated;
  final int elapsedDays;

  const LoginScreen({
    super.key, 
    required this.isActivated, 
    required this.elapsedDays,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isActivated && widget.elapsedDays > 30 && widget.elapsedDays <= 37) {
        int daysLeft = 37 - widget.elapsedDays;
        _showTrialWarning(daysLeft);
      }
    });
  }

  void _showTrialWarning(int daysLeft) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('تحذير: انتهاء الفترة التجريبية', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'النسخة غير مفعلة، يرجى تشغيل (مدير التراخيص) للتفعيل.\nيتبقى لك $daysLeft أيام فقط قبل إيقاف النظام وتصفير كافة البيانات المالية.',
          style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('متابعة العمل مؤقتاً', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🪄 نافذة تأكيد الإغلاق (في حال أراد الخروج قبل تسجيل الدخول)
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.power_settings_new, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('إغلاق النظام', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من أنك تريد إغلاق البرنامج بالكامل؟',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('تأكيد الإغلاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () => exit(0),
          ),
        ],
      ),
    );
  }

  void _onKeypadTap(String value) {
    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {
        context.read<AuthBloc>().add(LoginEvent(_pin));
      }
    }
  }

  void _onBackspaceTap() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // 🪄 إضافة زر عائم لإغلاق البرنامج من شاشة الدخول
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red,
        elevation: 0,
        icon: const Icon(Icons.power_settings_new),
        label: const Text('إغلاق البرنامج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: () => _showExitConfirmation(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // وضعه في أسفل اليسار
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/pos');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            setState(() => _pin = '');
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.lock_outline, size: 64, color: Colors.teal),
                  ),
                  const SizedBox(height: 24),
                  const Text('تسجيل الدخول', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  const Text('أدخل الرمز السري (PIN) للمتابعة', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  
                  _PinIndicatorWidget(pinLength: _pin.length),
                  const SizedBox(height: 40),
                  
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: _NumpadWidget(onKeypadTap: _onKeypadTap, onBackspaceTap: _onBackspaceTap),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinIndicatorWidget extends StatelessWidget {
  final int pinLength;
  const _PinIndicatorWidget({required this.pinLength});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index < pinLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.teal : Colors.grey.shade200,
            border: Border.all(color: isActive ? Colors.teal : Colors.grey.shade300, width: 2),
            boxShadow: isActive ? [BoxShadow(color: Colors.teal.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
        );
      }),
    );
  }
}

class _NumpadWidget extends StatelessWidget {
  final Function(String) onKeypadTap;
  final VoidCallback onBackspaceTap;
  const _NumpadWidget({required this.onKeypadTap, required this.onBackspaceTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildKey('1'), _buildKey('2'), _buildKey('3')]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildKey('4'), _buildKey('5'), _buildKey('6')]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildKey('7'), _buildKey('8'), _buildKey('9')]),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80),
            _buildKey('0'),
            SizedBox(
              width: 80, height: 80,
              child: IconButton(icon: const Icon(Icons.backspace_outlined, size: 32, color: Colors.redAccent), onPressed: onBackspaceTap),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String number) {
    return InkWell(
      onTap: () => onKeypadTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80, height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(number, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black87)),
      ),
    );
  }
}