import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/core/common/widgets/pos_dialog_components.dart'; // 🚀 استدعاء المكون المشترك

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
        createdAt: widget.category?.createdAt ?? DateTime.now(), 
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
        // 🚀 استخدام المكون المشترك للترويسة
        title: PosDialogHeader(
          title: isEditing ? 'تعديل القسم' : 'إضافة قسم جديد',
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
                    labelText: 'اسم القسم',
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: const BorderRadius.horizontal(right: Radius.circular(10))),
                      child: Icon(Icons.category, color: Colors.teal.shade800),
                    ),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'يرجى إدخال اسم القسم' : null,
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        // 🚀 استخدام المكون المشترك للأزرار
        actions: [
          PosDialogActions(onCancel: () => Navigator.pop(context), onSubmit: _submit),
        ],
      ),
    );
  }
}