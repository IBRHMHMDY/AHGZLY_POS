import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_bloc.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_event.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_state.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final TextEditingController _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LicenseBloc, LicenseState>(
        listener: (context, state) {
          if (state is LicenseActivationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تفعيل النظام بنجاح!'), backgroundColor: Colors.green),
            );
            context.go('/login');
          } else if (state is LicenseErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is LicenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security, size: 80, color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text(
                    'تفعيل النظام',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (state is LicenseExpiredState)
                    const Text(
                      'انتهت الفترة التجريبية، يرجى إدخال كود التفعيل.',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: 'كود التفعيل',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_keyController.text.isNotEmpty) {
                          context.read<LicenseBloc>().add(
                            ActivateLicenseSubmitEvent(licenseKey: _keyController.text),
                          );
                        }
                      },
                      child: const Text('تفعيل', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}