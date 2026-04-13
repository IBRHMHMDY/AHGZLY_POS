import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';

class CategoryDialog extends StatefulWidget {
  final CategoryEntity? category;

  const CategoryDialog({super.key, this.category});

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newCategory = CategoryEntity(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        createdAt: widget.category!.createdAt,
        updatedAt: DateTime.now(),
      );
      Navigator.pop(context, newCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: _DialogHeader(
          title: isEditing ? 'تعديل الفئة' : 'إضافة فئة جديدة',
          icon: isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'اسم الفئة',
                    labelStyle: TextStyle(color: Colors.teal.shade700),
                    filled: true,
                    fillColor: Colors.teal.shade50.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: const BorderRadius.horizontal(right: Radius.circular(10))),
                      child: Icon(Icons.category, color: Colors.teal.shade800),
                    ),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'يرجى إدخال اسم الفئة' : null,
                ),
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
}

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets) المستخرجة
// ==========================================

class _DialogHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DialogHeader({required this.title, required this.icon});

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
            child: Icon(icon, color: Colors.teal.shade800, size: 28),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
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
            child: const Text('إلغاء', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
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