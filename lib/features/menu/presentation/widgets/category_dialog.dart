import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';

class CategoryDialog extends StatefulWidget {
  final Category? category; // إذا كان null فهذا يعني إضافة، وإلا تعديل

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'إضافة فئة جديدة' : 'تعديل الفئة'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال اسم الفئة';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newCategory = Category(
                id: widget.category?.id,
                name: _nameController.text.trim(),
                createdAt: widget.category?.createdAt ?? DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              );
              Navigator.pop(context, newCategory);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}