import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/utils/extensions/print_mode.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/services/backup_service.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_event.dart';
import 'package:ahgzly_pos/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:ahgzly_pos/core/widgets/custom_shimmer.dart'; // 🪄 استيراد مكون الشيمر
import 'package:ahgzly_pos/features/license/presentation/bloc/license_bloc.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_event.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_state.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ahgzly_pos/features/auth/presentation/bloc/auth_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final BackupService _backupService = sl<BackupService>();

  List<Printer> _printers = [];
  bool _isLoadingPrinters = false;
  String? _selectedPrinterName;
  PrintMode _selectedPrintMode = PrintMode.ask;
  bool _isInit = false;

  late TextEditingController _taxController;
  late TextEditingController _serviceController;
  late TextEditingController _deliveryController;
  late TextEditingController _restaurantNameController;
  late TextEditingController _taxNumberController;

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettingsEvent());
    _taxController = TextEditingController();
    _serviceController = TextEditingController();
    _deliveryController = TextEditingController();
    _restaurantNameController = TextEditingController();
    _taxNumberController = TextEditingController();
    _fetchPrinters();
  }

  @override
  void dispose() {
    _taxController.dispose();
    _serviceController.dispose();
    _deliveryController.dispose();
    _restaurantNameController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchPrinters() async {
    setState(() => _isLoadingPrinters = true);
    try {
      final printers = await Printing.listPrinters();
      setState(() {
        _printers = printers;
        _isLoadingPrinters = false;
      });
    } catch (e) {
      setState(() => _isLoadingPrinters = false);
    }
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final newSettings = AppSettingsEntity(
        taxRate: double.parse(_taxController.text) / 100,
        serviceRate: double.parse(_serviceController.text) / 100,
        deliveryFee: MoneyFormatter.toCents(
          double.parse(_deliveryController.text.trim()),
        ),
        printerName: _selectedPrinterName ?? '',
        restaurantName: _restaurantNameController.text.trim(),
        taxNumber: _taxNumberController.text.trim(),
        printMode: _selectedPrintMode,
      );
      context.read<SettingsBloc>().add(SaveSettingsEvent(newSettings));
    }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تمت استعادة النسخة بنجاح. يرجى إعادة تشغيل التطبيق بالكامل.'
              : 'فشل استعادة النسخة الاحتياطية',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 5),
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
          if (state is SettingsLoading) {
            return const _SettingsShimmerLoading(); // 🪄 استخدام الشيمر
          }
          if (state is SettingsLoaded) {
            if (!_isInit) {
              final s = state.settings;
              _taxController.text = num.parse(
                (s.taxRate * 100).toStringAsFixed(2),
              ).toString();
              _serviceController.text = num.parse(
                (s.serviceRate * 100).toStringAsFixed(2),
              ).toString();
              _deliveryController.text = MoneyFormatter.format(s.deliveryFee);
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
                      // 🪄 1. البيانات الأساسية
                      _SettingsSectionCard(
                        title: 'البيانات الأساسية',
                        icon: Icons.store,
                        children: [
                          _CustomSettingsField(
                            controller: _restaurantNameController,
                            label: 'اسم المطعم (يظهر في الفاتورة)',
                            hint: 'مثال: مطعم الشيف',
                            icon: Icons.restaurant,
                          ),
                          const SizedBox(height: 16),
                          _CustomSettingsField(
                            controller: _taxNumberController,
                            label: 'الرقم الضريبي',
                            hint: 'مثال: 123-456-789',
                            icon: Icons.numbers,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 🪄 2. الرسوم والضرائب
                      _SettingsSectionCard(
                        title: 'الرسوم والضرائب',
                        icon: Icons.account_balance_wallet,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _CustomSettingsField(
                                  controller: _taxController,
                                  label: 'نسبة الضريبة المضافة (%)',
                                  hint: '14',
                                  icon: Icons.percent,
                                  isNumber: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _CustomSettingsField(
                                  controller: _serviceController,
                                  label: 'نسبة خدمة الصالة (%)',
                                  hint: '12',
                                  icon: Icons.room_service,
                                  isNumber: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _CustomSettingsField(
                            controller: _deliveryController,
                            label: 'رسوم التوصيل الثابتة (ج.م)',
                            hint: '20',
                            icon: Icons.delivery_dining,
                            isNumber: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 🪄 3. الأجهزة والطباعة
                      _SettingsSectionCard(
                        title: 'الأجهزة والطباعة',
                        icon: Icons.print,
                        children: [
                          _buildPrinterSelector(),
                          const SizedBox(height: 16),
                          _buildPrintModeSelector(),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 🪄 4. زر الحفظ الرئيسي
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
                        icon: const Icon(Icons.save_rounded, size: 28),
                        label: const Text(
                          'حفظ كافة الإعدادات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _saveSettings,
                      ),
                      const SizedBox(height: 48),

                      // 🪄 5. أدوات النظام المتقدمة
                      _SettingsSectionCard(
                        title: 'النسخ الاحتياطي (الأمان)',
                        icon: Icons.security,
                        titleColor: Colors.blueGrey.shade700,
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
                                  icon: const Icon(Icons.cloud_download),
                                  label: const Text(
                                    'إنشاء نسخة احتياطية',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                  icon: const Icon(Icons.cloud_upload),
                                  label: const Text(
                                    'استعادة نسخة سابقة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: _handleRestore,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 🪄 6. التراخيص
                      _SettingsSectionCard(
                        title: 'إدارة التراخيص (خطر)',
                        icon: Icons.key_off,
                        titleColor: Colors.red.shade900,
                        children: [
                          // 🪄 [ميزة جديدة]: عرض مدة التفعيل المتبقية وحالة الترخيص
                          BlocBuilder<LicenseBloc, LicenseState>(
                            builder: (context, state) {
                              if (state is LicenseValidState) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_user,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'النظام مفعل بنجاح',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            if (state.license.expiryDate !=
                                                null)
                                              Text(
                                                'متبقي ${state.license.remainingDays} يوم على الانتهاء',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.green,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: const Row(
                                      children: [
                                        Icon(
                                          Icons.warning_rounded,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'إلغاء التفعيل (خطر!)',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                      'هل أنت متأكد من إلغاء تفعيل البرنامج على هذا الجهاز؟\nسيتم تسجيل خروجك فوراً ولن يفتح النظام إلا بمفتاح تفعيل جديد.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                    actionsPadding: const EdgeInsets.all(20),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text(
                                          'تراجع',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.phonelink_erase),
                                        label: const Text(
                                          'تأكيد الإلغاء',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () async {
                                          // 1. مسح الترخيص الحقيقي من الذاكرة الآمنة
                                          const secureStorage =
                                              FlutterSecureStorage();
                                          await secureStorage.delete(
                                            key: 'app_secure_license_token',
                                          );

                                          // 2. مسح الترخيص من قاعدة البيانات المحلية (تنظيف إضافي)
                                          final db = sl<AppDatabase>();
                                          await (db.update(db.license)
                                                ..where((t) => t.id.equals(1)))
                                              .write(
                                                const LicenseCompanion(
                                                  isValid: drift.Value(false),
                                                  licenseKey: drift.Value(''),
                                                ),
                                              );

                                          // 🪄 3. تسجيل الخروج وتحديث حالة الترخيص حتى يسمح الراوتر بمرورنا
                                          if (ctx.mounted) {
                                            context.read<AuthBloc>().add(
                                              LogoutEvent(),
                                            ); // تفريغ حالة الدخول
                                            context.read<LicenseBloc>().add(
                                              CheckLicenseEvent(),
                                            ); // إجبار الراوتر على رؤية أن الترخيص اختفى
                                            Navigator.pop(ctx);
                                            context.go(
                                              '/license',
                                            ); // العودة الفورية لشاشة التفعيل
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
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
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ==========================================
  // مكونات فرعية محلية لتنظيف الدالة الرئيسية
  // ==========================================

  Widget _buildPrinterSelector() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value:
                (_selectedPrinterName != null &&
                    _printers.any((p) => p.name == _selectedPrinterName))
                ? _selectedPrinterName
                : null,
            decoration: _inputStyle(
              label: 'اختر الطابعة المتصلة',
              icon: Icons.print,
            ),
            items: _printers.map((Printer printer) {
              return DropdownMenuItem<String>(
                value: printer.name,
                child: Text(
                  '${printer.name} ${printer.isDefault ? "(الافتراضية)" : ""}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedPrinterName = val),
            validator: (value) =>
                value == null || value.isEmpty ? 'مطلوب تحديد طابعة' : null,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: _isLoadingPrinters
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: _fetchPrinters,
            tooltip: 'تحديث قائمة الطابعات',
          ),
        ),
      ],
    );
  }

  Widget _buildPrintModeSelector() {
    // [Refactored]: استخدام الـ Enum بشكل آلي ومحمي
    return DropdownButtonFormField<PrintMode>(
      value: _selectedPrintMode,
      decoration: _inputStyle(
        label: 'وضع الطباعة بعد الدفع',
        icon: Icons.settings_suggest,
      ),
      items: PrintMode.values.map((mode) {
        return DropdownMenuItem<PrintMode>(
          value: mode,
          child: Text(
            mode.toDisplayName(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedPrintMode = val);
      },
    );
  }

  InputDecoration _inputStyle({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.teal.shade700,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: Colors.teal.shade50.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(10),
          ),
        ),
        child: Icon(icon, color: Colors.teal.shade800),
      ),
    );
  }
}

// ==========================================
// 🪄 مكونات الواجهة المعزولة (Clean Widgets)
// ==========================================

class _CustomSettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isNumber;

  const _CustomSettingsField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.teal.shade700,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.teal.shade50.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(10),
            ),
          ),
          child: Icon(icon, color: Colors.teal.shade800),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }
}

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
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (titleColor ?? Colors.teal).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: titleColor ?? Colors.teal, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, thickness: 1),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsShimmerLoading extends StatelessWidget {
  const _SettingsShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            CustomShimmer.rectangular(
              height: 250,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            CustomShimmer.rectangular(
              height: 300,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            CustomShimmer.rectangular(
              height: 200,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
