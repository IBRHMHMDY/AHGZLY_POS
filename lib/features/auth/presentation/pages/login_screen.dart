import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// استيراد ملفات الوردية للتحقق منها بعد تسجيل الدخول
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../../../shift/presentation/bloc/shift_event.dart';
import '../../../shift/presentation/bloc/shift_state.dart';

import 'dart:io';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';
  static const int _maxPinLength = 6;

  void _onKeypadPressed(String value) {
    if (_pin.length < _maxPinLength) {
      setState(() {
        _pin += value;
      });
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _onSubmit() {
    if (_pin.isNotEmpty) {
      context.read<AuthBloc>().add(LoginSubmittedEvent(pin: _pin));
    }
  }

  // دالة إظهار رسالة التأكيد قبل الإغلاق لمنع الخروج بالخطأ
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('تأكيد الإغلاق', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من أنك تريد إغلاق نظام نقطة البيع (POS) بالكامل؟',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              // إغلاق البرنامج بالكامل بقوة
              exit(0);
            },
            child: const Text('تأكيد وإغلاق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showExitConfirmation, // استدعاء دالة التأكيد
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 8, // لزيادة البروز (Shadow)
        icon: const Icon(Icons.power_settings_new, size: 28),
        label: const Text(
          'إغلاق النظام',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      // تم تغيير BlocConsumer إلى MultiBlocListener لمراقبة الدخول والوردية معاً
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                // 1. الدخول ناجح -> لا تذهب للمبيعات! اطلب فحص الوردية أولاً
                context.read<ShiftBloc>().add(CheckActiveShiftEvent());
              } else if (state is AuthError) {
                setState(() { _pin = ''; });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
          BlocListener<ShiftBloc, ShiftState>(
            listener: (context, state) {
              if (state is ActiveShiftLoaded) {
                // 2. توجد وردية مفتوحة مسبقاً -> ادخل لبرنامج المبيعات مباشرة
                context.go(AppRouter.posPath);
              } else if (state is NoActiveShiftState) {
                // 3. لا توجد وردية نشطة -> وجه الكاشير إجبارياً لشاشة فتح الدرج
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.go(AppRouter.openShiftPath, extra: authState.user.id);
                }
              } else if (state is ShiftError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Center(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_person, size: 64, color: Colors.blueAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter PIN',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    
                    // حقل عرض الـ PIN (نقاط مخفية)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_maxPinLength, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _pin.length ? Colors.blueAccent : Colors.grey[300],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),

                    // لوحة الأرقام (Numpad)
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildNumpadButton('1'), _buildNumpadButton('2'), _buildNumpadButton('3'),
                        _buildNumpadButton('4'), _buildNumpadButton('5'), _buildNumpadButton('6'),
                        _buildNumpadButton('7'), _buildNumpadButton('8'), _buildNumpadButton('9'),
                        _buildIconButton(Icons.backspace_outlined, _onDeletePressed, Colors.redAccent),
                        _buildNumpadButton('0'),
                        _buildIconButton(Icons.check, _onSubmit, Colors.green),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    if (state is AuthLoading || context.read<ShiftBloc>().state is ShiftLoading)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumpadButton(String number) {
    return ElevatedButton(
      onPressed: () => _onKeypadPressed(number),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      child: Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
      ),
      child: Icon(icon, size: 28),
    );
  }
}