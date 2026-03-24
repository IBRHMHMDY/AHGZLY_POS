import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_bloc.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_event.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // إرسال حدث فحص الترخيص بمجرد فتح التطبيق
    context.read<LicenseBloc>().add(CheckLicenseEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: BlocListener<LicenseBloc, LicenseState>(
        listener: (context, state) {
          if (state is LicenseValidState) {
            // الترخيص ساري أو مفعل -> التوجيه لشاشة تسجيل الدخول
            context.go('/login');
          } else if (state is LicenseExpiredState) {
            // الترخيص منتهي أو غير مفعل -> التوجيه لشاشة التفعيل
            context.go('/license');
          } else if (state is LicenseErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.point_of_sale, size: 100, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Ahgzly POS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}