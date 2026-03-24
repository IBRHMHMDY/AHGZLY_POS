import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/services/backup_service.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_event.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _taxController;
  late TextEditingController _serviceController;
  late TextEditingController _deliveryController;
  late TextEditingController _printerController;
  late TextEditingController _restaurantNameController;
  late TextEditingController _taxNumberController;
  
  String _selectedPrintMode = 'ask';
  bool _isInit = false; // متغير لضمان عدم الكتابة فوق اختيار المستخدم
  final BackupService _backupService = BackupService();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettingsEvent());
    _taxController = TextEditingController();
    _serviceController = TextEditingController();
    _deliveryController = TextEditingController();
    _printerController = TextEditingController();
    _restaurantNameController = TextEditingController();
    _taxNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _taxController.dispose();
    _serviceController.dispose();
    _deliveryController.dispose();
    _printerController.dispose();
    _restaurantNameController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }

  void _handleBackup() async {
    final success = await _backupService.exportDatabase();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'تم حفظ النسخة الاحتياطية بنجاح' : 'فشل حفظ النسخة أو تم الإلغاء'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _handleRestore() async {
    final success = await _backupService.importDatabase();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت استعادة النسخة بنجاح. يرجى إعادة تشغيل التطبيق بالكامل.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل استعادة النسخة الاحتياطية'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات النظام', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsSavedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ الإعدادات بنجاح.'), backgroundColor: Colors.green),
              );
              Navigator.pop(context);
            } else if (state is SettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطأ: ${state.message}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is SettingsLoaded) {
              // نقوم بملء البيانات مرة واحدة فقط حتى لا نمسح تعديلات المستخدم أثناء كتابتها
              if (!_isInit) {
                final s = state.settings;
                _taxController.text = (s.taxRate * 100).toString();
                _serviceController.text = (s.serviceRate * 100).toString();
                _deliveryController.text = s.deliveryFee.toString();
                _printerController.text = s.printerName;
                _restaurantNameController.text = s.restaurantName;
                _taxNumberController.text = s.taxNumber;
                _selectedPrintMode = s.printMode;
                _isInit = true;
              }

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Text('البيانات الأساسية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const Divider(),
                      _buildTextField(_restaurantNameController, 'اسم المطعم (يظهر في الفاتورة)', 'مثال: مطعم الشيف'),
                      const SizedBox(height: 16),
                      _buildTextField(_taxNumberController, 'الرقم الضريبي', 'مثال: 123-456-789'),
                      const SizedBox(height: 32),
                      
                      const Text('الرسوم والضرائب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const Divider(),
                      _buildTextField(_taxController, 'نسبة الضريبة المضافة (%)', 'مثال: 14'),
                      const SizedBox(height: 16),
                      _buildTextField(_serviceController, 'نسبة خدمة الصالة (%)', 'مثال: 12'),
                      const SizedBox(height: 16),
                      _buildTextField(_deliveryController, 'رسوم التوصيل الثابتة (ج.م)', 'مثال: 20'),
                      const SizedBox(height: 32),

                      const Text('الأجهزة والطباعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const Divider(),
                      _buildTextField(_printerController, 'اسم طابعة الويندوز (USB Printer Name)', 'EPSON Printer'),
                      const SizedBox(height: 16),
                      
                      // القائمة المنسدلة للطباعة التلقائية
                      DropdownButtonFormField<String>(
                        value: _selectedPrintMode,
                        decoration: const InputDecoration(labelText: 'وضع الطباعة بعد الدفع', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'ask', child: Text('اسأل أولاً (عرض نافذة الطباعة)')),
                          DropdownMenuItem(value: 'customer', child: Text('طباعة فاتورة العميل تلقائياً')),
                          DropdownMenuItem(value: 'kitchen', child: Text('طباعة بون المطبخ تلقائياً')),
                          DropdownMenuItem(value: 'both', child: Text('طباعة العميل والمطبخ تلقائياً')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPrintMode = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16), 
                          backgroundColor: Colors.teal, 
                          foregroundColor: Colors.white
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newSettings = AppSettings(
                              taxRate: double.parse(_taxController.text) / 100,
                              serviceRate: double.parse(_serviceController.text) / 100,
                              deliveryFee: double.parse(_deliveryController.text),
                              printerName: _printerController.text.trim(),
                              restaurantName: _restaurantNameController.text.trim(),
                              taxNumber: _taxNumberController.text.trim(),
                              printMode: _selectedPrintMode, // هنا يتم حفظ الوضع الذي اختاره المستخدم
                            );
                            context.read<SettingsBloc>().add(SaveSettingsEvent(newSettings));
                          }
                        },
                        child: const Text('حفظ الإعدادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      
                      const SizedBox(height: 48),
                      const Text('النسخ الاحتياطي (الأمان)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                              icon: const Icon(Icons.download),
                              label: const Text('إنشاء نسخة احتياطية'),
                              onPressed: _handleBackup,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                              icon: const Icon(Icons.upload),
                              label: const Text('استعادة نسخة سابقة'),
                              onPressed: _handleRestore,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      validator: (value) => value!.isEmpty ? 'مطلوب' : null,
    );
  }
}