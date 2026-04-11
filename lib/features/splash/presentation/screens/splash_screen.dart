import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../license/presentation/bloc/license_bloc.dart';
import '../../../license/presentation/bloc/license_event.dart';
import '../../../license/presentation/bloc/license_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 🛡️ بدء عملية فحص سلامة النظام والترخيص فور فتح التطبيق
    context.read<LicenseBloc>().add(CheckLicenseEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LicenseBloc, LicenseState>(
      listener: (context, state) {
        if (state is LicenseValidState) {
          // الترخيص صالح والنظام آمن -> توجيه لشاشة الدخول/الكاشير
          context.go(AppRouter.loginPath); 
        } else if (state is LicenseInvalidState) {
          // تم اكتشاف تلاعب، أو انتهى الترخيص -> توجيه إجباري لشاشة التفعيل مع تمرير السبب
          context.go(AppRouter.licensePath, extra: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Refactored: توحيد الألوان مع شاشة LockScreen لبناء هوية بصرية متماسكة
              Icon(Icons.point_of_sale, size: 100, color: Colors.teal.shade700),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.teal),
              const SizedBox(height: 16),
              // Refactored: تعريب النص ليتوافق مع نظام الـ POS الخاص بنا
              Text(
                'جاري التحقق من سلامة النظام...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}