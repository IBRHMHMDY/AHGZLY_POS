import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemDialog extends StatefulWidget {
  final ItemEntity? item;
  final int initialCategoryId;
  final List<CategoryEntity> categories;

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
  late TextEditingController _costPriceController;
  late int _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
      text: widget.item != null ? widget.item!.price.toFormattedMoney() : '',
    );
    _costPriceController = TextEditingController(
      text: widget.item != null
          ? widget.item!.costPrice.toFormattedMoney()
          : '',
    );
    _selectedCategoryId = widget.item?.categoryId ?? widget.initialCategoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  void _onSubmit() {
  if (_formKey.currentState!.validate()) {
    // 1. تحويل النصوص إلى Double
    final priceDouble = double.parse(_priceController.text);
    final costPriceDouble = double.parse(_costPriceController.text);

    // 2. التحويل الآمن إلى قروش (Cents) باستخدام الإضافة الخاصة بك
    final priceCents = priceDouble.toCents();
    final costPriceCents = costPriceDouble.toCents();

    // التأكد من أن التكلفة لا تتجاوز سعر البيع (تنبيه منطقي للمدير)
    if (costPriceCents > priceCents) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تنبيه: سعر التكلفة أعلى من سعر البيع! هل أنت متأكد؟'),
          backgroundColor: Colors.orange,
        ),
      );
      // يمكن إيقاف الحفظ هنا بـ return، أو السماح به كتحذير فقط.
    }

    // 3. إنشاء الكيان الجديد
    final newItem = ItemEntity(
      id: widget.item?.id,
      categoryId: _selectedCategoryId,
      name: _nameController.text.trim(),
      price: priceCents,             // السعر بالقروش
      costPrice: costPriceCents,     // [NEW]: التكلفة بالقروش
      imagePath: widget.item?.imagePath,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // إرسال الـ Event للـ BLoC
    if (widget.item == null) {
      context.read<MenuBloc>().add(AddItemEvent(newItem));
    } else {
      context.read<MenuBloc>().add(UpdateItemEvent(newItem));
    }

    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: _DialogHeader(
          title: isEditing ? 'تعديل الصنف' : 'إضافة صنف جديد',
          icon: isEditing ? Icons.edit_note_rounded : Icons.fastfood_rounded,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🪄 1. اختيار الفئة التابع لها الصنف
                  _buildDropdownCategory(),
                  const SizedBox(height: 20),

                  // 🪄 2. اسم الصنف
                  _buildTextInput(
                    controller: _nameController,
                    label: 'اسم الصنف',
                    icon: Icons.restaurant_menu,
                    validatorMsg: 'يرجى إدخال اسم الصنف',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // حقل سعر التكلفة (مخفي عن الكاشير العادي في تقارير لاحقة، لكن المدير يدخله هنا)
                      Expanded(
                        child: TextFormField(
                          controller: _costPriceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'سعر التكلفة (ج.م)',
                            prefixIcon: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'مطلوب';
                            if (double.tryParse(value) == null) {
                              return 'قيمة غير صالحة';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // حقل سعر البيع للجمهور
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'سعر البيع (ج.م)',
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: Colors.teal,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'مطلوب';
                            if (double.tryParse(value) == null) {
                              return 'قيمة غير صالحة';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          _DialogActions(
            onCancel: () => Navigator.pop(context),
            onSubmit: _onSubmit,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🪄 مكونات واجهة الإدخال المخصصة
  // ==========================================

  Widget _buildDropdownCategory() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: _inputDecoration(
        label: 'القسم (الفئة)',
        icon: Icons.category,
      ),
      items: widget.categories.map((c) {
        return DropdownMenuItem(
          value: c.id,
          child: Text(
            c.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedCategoryId = val);
      },
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: _inputDecoration(label: label, icon: icon),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? validatorMsg : null,
    );
  }

  // Widget _buildPriceInput() {
  //   return TextFormField(
  //     controller: _priceController,
  //     keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //     style: TextStyle(
  //       fontSize: 20,
  //       fontWeight: FontWeight.w900,
  //       color: Colors.teal.shade800,
  //     ),
  //     decoration: _inputDecoration(label: 'سعر الصنف', icon: Icons.attach_money)
  //         .copyWith(
  //           suffixText: 'ج.م',
  //           suffixStyle: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             fontSize: 16,
  //             color: Colors.grey,
  //           ),
  //         ),
  //     validator: (value) {
  //       if (value == null || value.trim().isEmpty) return 'يرجى إدخال السعر';
  //       if (double.tryParse(value.trim()) == null) return 'رقم غير صحيح';
  //       return null;
  //     },
  //   );
  // }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.teal.shade700,
        fontWeight: FontWeight.w600,
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
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.teal.shade800, size: 28),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'حفظ البيانات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}
