import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _taxController = TextEditingController();
    _serviceController = TextEditingController();
    _deliveryController = TextEditingController();
    _printerController = TextEditingController();
  }

  @override
  void dispose() {
    _taxController.dispose();
    _serviceController.dispose();
    _deliveryController.dispose();
    _printerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات النظام'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsSavedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ الإعدادات بنجاح. أعد فتح شاشة الكاشير لتطبيقها.'), backgroundColor: Colors.green),
              );
              Navigator.pop(context); // العودة للكاشير
            } else if (state is SettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingsLoaded) {
              final s = state.settings;
              _taxController.text = (s.taxRate * 100).toString();
              _serviceController.text = (s.serviceRate * 100).toString();
              _deliveryController.text = s.deliveryFee.toString();
              _printerController.text = s.printerName;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextField(_taxController, 'نسبة الضريبة (%)', 'مثال: 14'),
                      const SizedBox(height: 16),
                      _buildTextField(_serviceController, 'نسبة خدمة الصالة (%)', 'مثال: 12'),
                      const SizedBox(height: 16),
                      _buildTextField(_deliveryController, 'رسوم التوصيل الثابتة (ج.م)', 'مثال: 20'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _printerController,
                        decoration: const InputDecoration(
                          labelText: 'اسم طابعة الويندوز (USB Printer Name)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newSettings = AppSettings(
                              taxRate: double.parse(_taxController.text) / 100,
                              serviceRate: double.parse(_serviceController.text) / 100,
                              deliveryFee: double.parse(_deliveryController.text),
                              printerName: _printerController.text.trim(),
                            );
                            context.read<SettingsBloc>().add(SaveSettingsEvent(newSettings));
                          }
                        },
                        child: const Text('حفظ الإعدادات', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('جاري تحميل الإعدادات...'));
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      validator: (value) => value!.isEmpty ? 'مطلوب' : null,
    );
  }
}