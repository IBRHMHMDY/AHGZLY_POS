import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';

class ItemDialog extends StatefulWidget {
  final Item? item;
  final int categoryId;

  const ItemDialog({super.key, this.item, required this.categoryId});

  @override
  State<ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'إضافة صنف جديد' : 'تعديل الصنف'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الصنف',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'يرجى إدخال اسم الصنف';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'يرجى إدخال السعر';
                if (double.tryParse(value) == null) return 'يرجى إدخال رقم صحيح';
                return null;
              },
            ),
          ],
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
              final newItem = Item(
                id: widget.item?.id,
                categoryId: widget.categoryId,
                name: _nameController.text.trim(),
                price: double.parse(_priceController.text.trim()),
                createdAt: widget.item?.createdAt ?? DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              );
              Navigator.pop(context, newItem);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}