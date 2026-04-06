import 'dart:io';
import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/services/backup_service.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_event.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_state.dart';
import 'package:printing/printing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Printer> _printers = [];
  bool _isLoadingPrinters = false;
  String? _selectedPrinterName;
  late TextEditingController _taxController;
  late TextEditingController _serviceController;
  late TextEditingController _deliveryController;
  // late TextEditingController _printerController;
  late TextEditingController _restaurantNameController;
  late TextEditingController _taxNumberController;

  String _selectedPrintMode = 'ask';
  bool _isInit = false;
  final BackupService _backupService = BackupService();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettingsEvent());
    _taxController = TextEditingController();
    _serviceController = TextEditingController();
    _deliveryController = TextEditingController();
    // _printerController = TextEditingController();
    _fetchPrinters();
    _restaurantNameController = TextEditingController();
    _taxNumberController = TextEditingController();
  }

  Future<void> _fetchPrinters() async {
    setState(() => _isLoadingPrinters = true);
    try {
      // هذه الدالة تجلب كل الطابعات المعرفة في Windows و Android
      final printers = await Printing.listPrinters();
      setState(() {
        _printers = printers;
        _isLoadingPrinters = false;
      });
    } catch (e) {
      setState(() => _isLoadingPrinters = false);
    }
  }

  @override
  void dispose() {
    _taxController.dispose();
    _serviceController.dispose();
    _deliveryController.dispose();
    // _printerController.dispose();
    _restaurantNameController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }

  void _handleBackup() async {
    final success = await _backupService.exportDatabase();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تم حفظ النسخة الاحتياطية بنجاح'
              : 'فشل حفظ النسخة أو تم الإلغاء',
        ),
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
          content: Text(
            'تمت استعادة النسخة بنجاح. يرجى إعادة تشغيل التطبيق بالكامل.',
          ),
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

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final newSettings = AppSettings(
        taxRate: double.parse(_taxController.text) / 100,
        serviceRate: double.parse(_serviceController.text) / 100,
        deliveryFee: double.parse(_deliveryController.text),
        printerName: _selectedPrinterName ?? '',
        restaurantName: _restaurantNameController.text.trim(),
        taxNumber: _taxNumberController.text.trim(),
        printMode: _selectedPrintMode,
      );
      context.read<SettingsBloc>().add(SaveSettingsEvent(newSettings));
    }
  }

  void _deactivateLicense() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('إلغاء التفعيل!', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من إلغاء تفعيل البرنامج على هذا الجهاز؟\nسيتم إغلاق البرنامج فوراً ولن يفتح مجدداً إلا بمفتاح تفعيل جديد.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // 1. تصفير قاعدة البيانات
              final db = await DatabaseHelper().database;
              await db.update('license', {
                'is_activated': 0,
                'license_key': '',
              }, where: 'id = 1');

              // 2. إغلاق البرنامج بقوة (للكمبيوتر)
              exit(0);
            },
            child: const Text('تأكيد وإغلاق البرنامج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 8),
            Text(
              'إعدادات النظام',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsSavedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ الإعدادات بنجاح.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoaded) {
            if (!_isInit) {
              final s = state.settings;
              _taxController.text = num.parse((s.taxRate * 100).toStringAsFixed(2)).toString();
              _serviceController.text = num.parse((s.serviceRate * 100).toStringAsFixed(2)).toString();
              _deliveryController.text = num.parse(s.deliveryFee.toStringAsFixed(2)).toString();
              _selectedPrinterName = s.printerName;
              _restaurantNameController.text = s.restaurantName;
              _taxNumberController.text = s.taxNumber;
              _selectedPrintMode = s.printMode;
              _isInit = true;
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      _SettingsSectionCard(
                        title: 'البيانات الأساسية',
                        icon: Icons.store,
                        children: [
                          _buildTextField(
                            _restaurantNameController,
                            'اسم المطعم (يظهر في الفاتورة)',
                            'مثال: مطعم الشيف',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _taxNumberController,
                            'الرقم الضريبي',
                            'مثال: 123-456-789',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _SettingsSectionCard(
                        title: 'الرسوم والضرائب',
                        icon: Icons.account_balance_wallet,
                        children: [
                          _buildTextField(
                            _taxController,
                            'نسبة الضريبة المضافة (%)',
                            'مثال: 14',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _serviceController,
                            'نسبة خدمة الصالة (%)',
                            'مثال: 12',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _deliveryController,
                            'رسوم التوصيل الثابتة (ج.م)',
                            'مثال: 20',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _SettingsSectionCard(
                        title: 'الأجهزة والطباعة',
                        icon: Icons.print,
                        children: [
                          // Select Printer
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  // التأكد من أن الاسم المحفوظ موجود فعلاً في قائمة الطابعات
                                  value: (_selectedPrinterName != null && 
                                          _printers.any((p) => p.name == _selectedPrinterName))
                                      ? _selectedPrinterName
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'اختر الطابعة المتصلة',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  items: _printers.map((Printer printer) {
                                    return DropdownMenuItem<String>(
                                      value: printer.name,
                                      child: Text(
                                        '${printer.name} ${printer.isDefault ? "(الافتراضية)" : ""}',
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedPrinterName = val;
                                    });
                                  },
                                  validator: (value) => value == null || value.isEmpty ? 'مطلوب تحديد طابعة' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: _isLoadingPrinters
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Icon(Icons.refresh, color: Colors.white),
                                  onPressed: _fetchPrinters,
                                  tooltip: 'تحديث قائمة الطابعات',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedPrintMode,
                            decoration: InputDecoration(
                              labelText: 'وضع الطباعة بعد الدفع',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'ask',
                                child: Text('اسأل أولاً (عرض نافذة الطباعة)'),
                              ),
                              DropdownMenuItem(
                                value: 'customer',
                                child: Text('طباعة فاتورة العميل تلقائياً'),
                              ),
                              DropdownMenuItem(
                                value: 'kitchen',
                                child: Text('طباعة بون المطبخ تلقائياً'),
                              ),
                              DropdownMenuItem(
                                value: 'both',
                                child: Text('طباعة العميل والمطبخ تلقائياً'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedPrintMode = val);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.save, size: 28),
                        label: const Text(
                          'حفظ الإعدادات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _saveSettings,
                      ),

                      const SizedBox(height: 48),

                      _SettingsSectionCard(
                        title: 'النسخ الاحتياطي (الأمان)',
                        icon: Icons.security,
                        titleColor: Colors.red.shade700,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade800,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.download),
                                  label: const Text(
                                    'إنشاء نسخة احتياطية',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  onPressed: _handleBackup,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.upload),
                                  label: const Text(
                                    'استعادة نسخة سابقة',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  onPressed: _handleRestore,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _SettingsSectionCard(
                        title: 'إدارة التراخيص (خطر)',
                        icon: Icons.key_off,
                        titleColor: Colors.red.shade900,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                              icon: const Icon(Icons.phonelink_erase),
                              label: const Text(
                                'إلغاء تفعيل النسخة الحالية (للنقل لجهاز آخر)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _deactivateLicense,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
    );
  }
}

// ==========================================
// Widgets المعزولة لتطبيق مبدأ Clean Code
// ==========================================

class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? titleColor;

  const _SettingsSectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: titleColor ?? Colors.teal, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          ...children,
        ],
      ),
    );
  }
}
