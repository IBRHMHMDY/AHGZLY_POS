import 'package:ahgzly_pos/core/common/enums/enums_data.dart';
import 'package:ahgzly_pos/core/extensions/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_bloc.dart';
import 'package:ahgzly_pos/features/users/presentation/bloc/users_event.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  UserRole _selectedRole = UserRole.cashier; // افتراضياً كاشير

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<UsersBloc>().add(
        AddUserEvent(
          name: _nameController.text.trim(),
          role: _selectedRole,
          pin: _pinController.text.trim(),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: const _DialogHeader(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        content: SizedBox(
          width: 450,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNameField(),
                const SizedBox(height: 20),
                _buildRoleDropdown(),
                const SizedBox(height: 20),
                _buildPinField(),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          _DialogActions(onCancel: () => Navigator.pop(context), onSubmit: _submit),
        ],
      ),
    );
  }

  // ==========================================
  // 🪄 مكونات واجهة الإدخال
  // ==========================================

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: _inputDecoration(label: 'اسم المستخدم', icon: Icons.person_outline),
      validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال اسم المستخدم' : null,
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<UserRole>(
      value: _selectedRole,
      decoration: _inputDecoration(label: 'الصلاحية', icon: Icons.admin_panel_settings),
      items: UserRole.values.map((role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Text(
            role.toDisplayName(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: role == UserRole.admin ? Colors.red : Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedRole = val);
      },
    );
  }

  Widget _buildPinField() {
    return TextFormField(
      controller: _pinController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      obscureText: true,
      maxLength: 6,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8, color: Colors.teal),
      decoration: _inputDecoration(label: 'الرمز السري (PIN)', icon: Icons.password).copyWith(
        counterText: '', // إخفاء عداد الأحرف من الأسفل
        hintText: '****',
        hintStyle: const TextStyle(letterSpacing: 8),
      ),
      validator: (val) {
        if (val == null || val.length < 4) return 'الرمز السري يجب أن يكون 4 أرقام على الأقل';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: Colors.teal.shade50.withOpacity(0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: const BorderRadius.horizontal(right: Radius.circular(10))),
        child: Icon(icon, color: Colors.teal.shade800),
      ),
    );
  }
}

// ==========================================
// 🪄 المكونات الفرعية للنوافذ
// ==========================================

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.teal.shade100, shape: BoxShape.circle),
            child: Icon(Icons.person_add_alt_1_rounded, color: Colors.teal.shade800, size: 28),
          ),
          const SizedBox(width: 12),
          Text('إضافة مستخدم جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.teal.shade900)),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _DialogActions({required this.onCancel, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('حفظ البيانات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}