import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:ahgzly_pos/core/common/widgets/pos_numpad.dart'; // المكون المشترك
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../../../shift/presentation/bloc/shift_event.dart';
import '../../../shift/presentation/bloc/shift_state.dart';

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
      setState(() => _pin += value);
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _onSubmit() {
    if (_pin.isNotEmpty) {
      context.read<AuthBloc>().add(LoginSubmittedEvent(pin: _pin));
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.power_settings_new_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('تأكيد إغلاق النظام', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text('هل أنت متأكد من أنك تريد إغلاق نظام نقطة البيع (POS) بالكامل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('تأكيد وإغلاق'),
            onPressed: () => exit(0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.teal.shade50,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showExitConfirmation,
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.power_settings_new),
          label: const Text('إغلاق النظام'),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.read<ShiftBloc>().add(CheckActiveShiftEvent());
                } else if (state is AuthError) {
                  setState(() => _pin = '');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
                }
              },
            ),
            BlocListener<ShiftBloc, ShiftState>(
              listener: (context, state) {
                if (state is ActiveShiftLoaded) {
                  context.go(AppRoutes.pos); // تم استخدام الثابت من AppRoutes
                } else if (state is NoActiveShiftState) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.go(AppRoutes.openShift, extra: authState.user.id);
                  }
                } else if (state is ShiftError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
                }
              },
            ),
          ],
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = (state is AuthLoading || context.read<ShiftBloc>().state is ShiftLoading);

              return Center(
                child: Container(
                  width: 420,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                        child: const Icon(Icons.lock_person_rounded, size: 70, color: Colors.teal),
                      ),
                      const SizedBox(height: 24),
                      const Text('تسجيل الدخول', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      const Text('يرجى إدخال الرمز السري (PIN) للمتابعة', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 32),
                      
                      PinDots(pinLength: _pin.length, maxLength: _maxPinLength),
                      const SizedBox(height: 40),

                      PosNumpad(
                        onNumberPressed: _onKeypadPressed,
                        onDeletePressed: _onDeletePressed,
                        onSubmitPressed: _onSubmit,
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