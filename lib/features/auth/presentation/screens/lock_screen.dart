import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/routing/app_router.dart';
import 'package:ahgzly_pos/core/common/widgets/pos_numpad.dart'; // المكون المشترك
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_state.dart';
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  static const int _maxPinLength = 6;
  User? _cachedUser; 

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _cachedUser = authState.user;
    }
  }

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

  void _onUnlock() {
    if (_pin.isEmpty) return;
    
    if (_cachedUser != null) {
      context.read<AuthBloc>().add(
        UnlockSubmittedEvent(pin: _pin, currentUser: _cachedUser!)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ. يرجى إعادة تشغيل التطبيق.'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.teal.shade900,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.pos);
              }
            } else if (state is AuthError) {
              setState(() => _pin = '');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red)
              );
            }
          },
          child: Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 80, color: Colors.teal),
                      const SizedBox(height: 24),
                      const Text('تم قفل الشاشة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        _cachedUser != null ? 'مرحباً ${_cachedUser!.name}' : 'أدخل رمز المرور للمتابعة', 
                        style: const TextStyle(fontSize: 16, color: Colors.grey)
                      ),
                      const SizedBox(height: 32),
                      
                      PinDots(pinLength: _pin.length, maxLength: _maxPinLength),
                      const SizedBox(height: 40),
                      
                      PosNumpad(
                        onNumberPressed: _onKeypadPressed,
                        onDeletePressed: _onDeletePressed,
                        onSubmitPressed: _onUnlock,
                        isLoading: isLoading,
                        submitIcon: Icons.lock_open_rounded, // أيقونة فك القفل
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}