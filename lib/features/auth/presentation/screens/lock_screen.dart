import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/common/entities/user.dart';
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
  final _pinController = TextEditingController();
  String? _errorMessage;

  void _unlock() {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    setState(() => _errorMessage = null);
    context.read<AuthBloc>().add(
      UnlockSubmittedEvent(pin: pin, currentUser: widget.currentUser),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.teal.shade900, // خلفية داكنة لإعطاء إيحاء القفل
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnlocked) {
                context.pop(); 
              } else if (state is AuthError) {
                setState(() {
                  _errorMessage = state.message;
                  _pinController.clear();
                });
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
                      const SizedBox(height: 40),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        obscureText: true,
                        autofocus: true,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 32, letterSpacing: 12, color: Colors.teal, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '****',
                          hintStyle: const TextStyle(letterSpacing: 12),
                          counterText: '',
                          errorText: _errorMessage,
                          errorStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
                        ),
                        onSubmitted: (_) => _unlock(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                          ),
                          onPressed: isLoading ? null : _unlock,
                          icon: isLoading ? const SizedBox.shrink() : const Icon(Icons.lock_open_rounded),
                          label: isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Text('إلغاء القفل والمتابعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
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