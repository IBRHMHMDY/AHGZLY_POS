import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/security/device_security_service.dart';
import '../bloc/license_bloc.dart';
import '../bloc/license_event.dart';
import '../bloc/license_state.dart';

class LicenseScreen extends StatefulWidget {
  final String? errorMessage;
  const LicenseScreen({super.key, this.errorMessage});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final TextEditingController _keyController = TextEditingController();
  String _deviceId = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    // جلب رقم الجهاز الفعلي لعرضه للعميل
    final deviceId = await sl<DeviceSecurityService>().getUniqueDeviceId();
    setState(() {
      _deviceId = deviceId;
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Activation'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<LicenseBloc, LicenseState>(
        listener: (context, state) {
          if (state is LicenseActivationSuccessState || state is LicenseValidState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('System activated successfully!'), backgroundColor: Colors.green),
            );
            context.go(AppRouter.loginPath);
          } else if (state is LicenseErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is LicenseInvalidState) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
                  const SizedBox(height: 24),
                  
                  if (widget.errorMessage != null || state is LicenseInvalidState)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (state is LicenseInvalidState) ? state.message : widget.errorMessage ?? 'System Locked',
                        style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // --- قسم عرض رقم الجهاز للعميل ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade200,
                    child: Column(
                      children: [
                        const Text('Your Device ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SelectableText(_deviceId, style: const TextStyle(fontSize: 16, color: Colors.blueAccent)),
                        TextButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy to send to Admin'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _deviceId));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ------------------------------------

                  TextField(
                    controller: _keyController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Secure License Key',
                      hintText: 'Paste your encrypted activation key here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is LicenseLoading 
                        ? null 
                        : () {
                            if (_keyController.text.trim().isNotEmpty) {
                              context.read<LicenseBloc>().add(
                                ActivateLicenseSubmitEvent(licenseKey: _keyController.text.trim())
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is LicenseLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Verify & Activate', style: TextStyle(fontSize: 18)),
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