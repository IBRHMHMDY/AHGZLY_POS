import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';

  void _onKeypadTap(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
      });
      // تسجيل الدخول تلقائياً عند اكتمال 4 أرقام
      if (_pin.length == 4) {
        context.read<AuthBloc>().add(LoginEvent(_pin));
      }
    }
  }

  void _onBackspaceTap() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // توحيد لون الخلفية مع النظام
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/pos'); // الانتقال للكاشير بعد النجاح
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
            setState(() {
              _pin = ''; // تفريغ الخانة عند الخطأ
            });
          }
        },
        child: Center(
          // 🪄 إضافة SingleChildScrollView لحماية الشاشة من أي Overflow عمودي
          child: SingleChildScrollView(
            child: Container(
              // 🪄 استخدام constraints ليكون العرض مرناً (Responsive) وليس ثابتاً
              constraints: const BoxConstraints(maxWidth: 450),
              margin: const EdgeInsets.all(16), // مسافة أمان حتى لا يلتصق بالحواف
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline, size: 64, color: Colors.teal),
                  ),
                  const SizedBox(height: 24),
                  const Text('تسجيل الدخول', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  const Text('أدخل الرمز السري (PIN) للمتابعة', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  
                  // استخدام Widget منفصل لدوائر الرقم السري
                  _PinIndicatorWidget(pinLength: _pin.length),
                  
                  const SizedBox(height: 40),
                  
                  // إجبار لوحة الأرقام فقط لتكون من اليسار لليمين (LTR)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: _NumpadWidget(
                      onKeypadTap: _onKeypadTap,
                      onBackspaceTap: _onBackspaceTap,
                    ),
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

// ==========================================
// Widgets المعزولة لتطبيق مبدأ Clean Code
// ==========================================

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
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.teal : Colors.grey.shade200,
            border: Border.all(
              color: isActive ? Colors.teal : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.teal.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                : [],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildKey('1'), _buildKey('2'), _buildKey('3')],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildKey('4'), _buildKey('5'), _buildKey('6')],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildKey('7'), _buildKey('8'), _buildKey('9')],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // مسافة فارغة
            _buildKey('0'),
            SizedBox(
              width: 80,
              height: 80,
              child: IconButton(
                icon: const Icon(Icons.backspace_outlined, size: 32, color: Colors.redAccent),
                onPressed: onBackspaceTap,
              ),
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
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Text(number, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black87)),
      ),
    );
  }
}