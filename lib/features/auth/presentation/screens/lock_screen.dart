import 'package:flutter/material.dart';
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

    // Refactored: Dispatch event instead of calling UseCase directly
    context.read<AuthBloc>().add(
      UnlockSubmittedEvent(pin: pin, currentUser: widget.currentUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      child: Scaffold(
        backgroundColor: Colors.teal.shade700, 
        // Refactored: Use BlocConsumer to handle loading and errors cleanly
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnlocked) {
              context.pop(); // Pop back to POS screen on success
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
                width: 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 80, color: Colors.teal),
                    const SizedBox(height: 16),
                    const Text('الشاشة مقفلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('الكاشير الحالي: ${widget.currentUser.name}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      autofocus: true,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8),
                      decoration: InputDecoration(
                        hintText: 'أدخل الرمز السري',
                        errorText: _errorMessage, // Updated reactively by BlocListener
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (_) => _unlock(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isLoading ? null : _unlock,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('إلغاء القفل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}