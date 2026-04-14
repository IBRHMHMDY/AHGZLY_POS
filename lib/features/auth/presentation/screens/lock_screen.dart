import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:ahgzly_pos/core/widgets/custom_numpad.dart'; // 🪄 استيراد الويدجت المشتركة
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';

class LockScreen extends StatefulWidget {
  final User currentUser;
  const LockScreen({super.key, required this.currentUser});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  static const int _maxPinLength = 6;

  void _onKeypadPressed(String value) {
    if (_pin.length < _maxPinLength) {
      setState(() => _pin += value);
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _unlock() {
    if (_pin.isNotEmpty) {
      context.read<AuthBloc>().add(
        UnlockSubmittedEvent(pin: _pin, currentUser: widget.currentUser),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.teal.shade900, 
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnlocked) {
                if (state.user.isAdmin) {
                  context.go(AppRouter.adminDashboardPath); // توجيه المدير للوحة التحكم
                } else {
                  context.go(AppRouter.posPath); // توجيه الكاشير لشاشة البيع
                }
              } else if (state is AuthError) {
                setState(() => _pin = '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Center(
                child: Container(
                  width: 420,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                        child: const Icon(Icons.lock_rounded, size: 70, color: Colors.teal),
                      ),
                      const SizedBox(height: 24),
                      const Text('شاشة نقطة البيع مقفلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'الكاشير الحالي: ${widget.currentUser.name}', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // 🪄 استخدام الويدجت المشتركة بدلاً من كتابة كود مكرر
                      PinDots(pinLength: _pin.length, maxLength: _maxPinLength),
                      const SizedBox(height: 40),

                      // 🪄 استخدام الـ Numpad المشترك
                      CustomNumpad(
                        onNumberPressed: _onKeypadPressed,
                        onDeletePressed: _onDeletePressed,
                        onSubmitPressed: _unlock,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}