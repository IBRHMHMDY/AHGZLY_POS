import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/common/entities/user.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/features/auth/domain/usecases/login_usecase.dart';

class LockScreen extends StatefulWidget {
  final User currentUser;
  const LockScreen({super.key, required this.currentUser});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _unlock() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // استخدام UseCase الخاص بتسجيل الدخول للتحقق من صحة الرمز
    final loginUseCase = sl<LoginUseCase>();
    final result = await loginUseCase.call(pin); // عدّل الباراميتر إذا كان يحتاج كائن Params

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'الرمز السري غير صحيح';
          _pinController.clear();
        });
      },
      (user) {
        // التحقق الأمني: هل الرمز يخص الكاشير الحالي؟ أو هل هو مدير؟
        if (user.id == widget.currentUser.id || user.isAdmin) {
          context.pop(); // فك القفل والعودة للكاشير
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'يجب إدخال الرمز الخاص بك (${widget.currentUser.name}) أو رمز المدير';
            _pinController.clear();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // منع الخروج من الشاشة بزر الرجوع
      child: Scaffold(
        backgroundColor: Colors.teal.shade700, // لون داكن لحجب الرؤية
        body: Center(
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
                    errorText: _errorMessage,
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
                    onPressed: _isLoading ? null : _unlock,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('إلغاء القفل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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