import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ahgzly_pos/core/database/database_helper.dart';

class LicenseScreen extends StatefulWidget {
  final bool isTrialExpired;

  const LicenseScreen({super.key, this.isTrialExpired = false});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  String _deviceId = 'جاري قراءة اللوحة الأم...';
  String _shortId = '';
  final _keyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isWindows) {
      final winInfo = await deviceInfo.windowsInfo;
      _deviceId = winInfo.deviceId;
    } else {
      _deviceId = 'TEST-DEVICE-ID-12345';
    }
    
    if (mounted) {
      setState(() {
        _shortId = _deviceId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').substring(0, 6).toUpperCase();
      });
    }
  }

void _verifyKey() async {
    final expectedKey = "AHGZLY-$_shortId-2026";
    
    if (_keyController.text.trim() == expectedKey) {
      setState(() => _isLoading = true);
      
      // تحديث قاعدة البيانات
      final db = await DatabaseHelper().database;
      await db.update('license', {'is_activated': 1, 'license_key': expectedKey}, where: 'id = 1');
      
      // إيقاف التحميل وإظهار رسالة النجاح
      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('تم التفعيل بنجاح!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'مبروك! تم تفعيل نسختك بشكل دائم.\nسيتم إغلاق البرنامج الآن لتطبيق إعدادات التفعيل. يرجى إعادة تشغيله.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            actions: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.power_settings_new),
                label: const Text('إغلاق البرنامج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () => exit(0), // يقوم بإغلاق البرنامج فوراً
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مفتاح التفعيل غير صحيح! تواصل مع الدعم الفني.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isTrialExpired)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                  child: const Row(
                    children: [
                      Icon(Icons.block, color: Colors.red, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'انتهت الفترة التجريبية (37 يوم) وتم إيقاف النظام وحذف البيانات المالية. يرجى التفعيل لاستعادة الوصول للنظام.',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.security_outlined, size: 72, color: Colors.teal),
              ),
              const SizedBox(height: 24),
              const Text('تفعيل النظام', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              const Text(
                'يرجى إرسال رقم الجهاز للمطور للحصول على مفتاح التفعيل.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('رقم الجهاز الخاص بك:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      _shortId.isEmpty ? '...' : _shortId,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _keyController,
                style: const TextStyle(fontSize: 22, letterSpacing: 2, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'أدخل مفتاح التفعيل (License Key)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.key, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  onPressed: _isLoading || _shortId.isEmpty ? null : _verifyKey,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('تفعيل البرنامج الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}