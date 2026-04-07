import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';

class ItemDialog extends StatefulWidget {
  final Item? item;
  final int initialCategoryId;
  final List<Category> categories;

  const ItemDialog({
    super.key, 
    this.item, 
    required this.initialCategoryId, 
    required this.categories,
  });

  @override
  State<ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late int _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
  text: widget.item != null ? MoneyFormatter.format(widget.item!.price) : ''
);
    _selectedCategoryId = widget.item?.categoryId ?? widget.initialCategoryId;
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(widget.item == null ? Icons.fastfood : Icons.edit, color: Colors.teal),
          const SizedBox(width: 8),
          Text(widget.item == null ? 'إضافة صنف جديد' : 'تعديل ونقل الصنف', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'اسم الصنف',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.restaurant_menu),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'السعر (ج.م)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'مطلوب';
                  if (double.tryParse(value) == null) return 'رقم غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'تخصيص للفئة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategoryId = val);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newItem = Item(
                id: widget.item?.id,
                categoryId: _selectedCategoryId,
                name: _nameController.text.trim(),
                price: MoneyFormatter.toCents(double.parse(_priceController.text.trim())),
                createdAt: widget.item?.createdAt ?? DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              );
              Navigator.pop(context, newItem);
            }
          },
          child: const Text('حفظ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}