import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  final TextEditingController _pinController = TextEditingController();
  bool _isObscured = true;
  String? _errorMessage;
  
  User? _cachedUser; 

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _cachedUser = authState.user;
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onUnlock() {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'يرجى إدخال رمز المرور (PIN)');
      return;
    }
    
    if (_cachedUser != null) {
      context.read<AuthBloc>().add(
        UnlockSubmittedEvent(pin: pin, currentUser: _cachedUser!)
      );
    } else {
      setState(() => _errorMessage = 'حدث خطأ. يرجى إعادة تشغيل التطبيق.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // 🚀 التوجيه الآمن لشاشة الكاشير
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/pos');
            }
          } else if (state is AuthError) {
            setState(() {
              _errorMessage = state.message;
              _pinController.clear();
            });
          }
        },
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.teal),
                const SizedBox(height: 24),
                const Text('تم قفل الشاشة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Text(
                  _cachedUser != null ? 'مرحباً ${_cachedUser!.name}' : 'أدخل رمز المرور للمتابعة', 
                  style: const TextStyle(fontSize: 16, color: Colors.grey)
                ),
                const SizedBox(height: 32),
                
                TextField(
                  controller: _pinController,
                  obscureText: _isObscured,
                  keyboardType: TextInputType.number,
                  maxLength: 6, 
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, 
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: "", 
                    hintText: '******',
                    errorText: _errorMessage,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isObscured = !_isObscured),
                    ),
                  ),
                  onSubmitted: (_) => _onUnlock(),
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: _onUnlock,
                    child: const Text('فــك الـقـفـل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}