import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_variant_entity.dart';
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
  
  // 🚀 قائمة المقاسات المرتبطة بهذا الصنف
  List<ItemVariantEntity> _variants = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
      text: widget.item != null ? widget.item!.price.toFormattedMoney() : '',
    );
    _costPriceController = TextEditingController(
      text: widget.item != null ? widget.item!.costPrice.toFormattedMoney() : '',
    );
    _selectedCategoryId = widget.item?.categoryId ?? widget.initialCategoryId;
    
    // تحميل المقاسات إذا كنا في وضع التعديل
    if (widget.item != null && widget.item!.variants.isNotEmpty) {
      _variants = List.from(widget.item!.variants);
    }
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
      final priceDouble = double.parse(_priceController.text);
      final costPriceDouble = double.parse(_costPriceController.text);

      final priceCents = priceDouble.toCents();
      final costPriceCents = costPriceDouble.toCents();

      if (costPriceCents > priceCents) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تنبيه: سعر التكلفة أعلى من سعر البيع!'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // 🚀 إرسال الصنف مع مقاساته
      final newItem = ItemEntity(
        id: widget.item?.id,
        categoryId: _selectedCategoryId,
        name: _nameController.text.trim(),
        price: priceCents,             
        costPrice: costPriceCents,     
        imagePath: widget.item?.imagePath,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        variants: _variants, // تمرير المقاسات للـ Entity
      );

      if (widget.item == null) {
        context.read<MenuBloc>().add(AddItemEvent(newItem));
      } else {
        context.read<MenuBloc>().add(UpdateItemEvent(newItem));
      }

      Navigator.pop(context);
    }
  }

  // 🚀 نافذة منبثقة صغيرة لإضافة مقاس جديد للصنف
  void _showAddVariantDialog() {
    final vNameCtrl = TextEditingController();
    final vPriceCtrl = TextEditingController();
    final vCostCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة مقاس جديد (مثال: كبير، وسط)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextInput(controller: vNameCtrl, label: 'اسم المقاس', icon: Icons.straighten, validatorMsg: 'مطلوب'),
              const SizedBox(height: 12),
              TextFormField(
                controller: vPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(label: 'سعر البيع (ج.م)', icon: Icons.attach_money),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: vCostCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(label: 'سعر التكلفة (ج.م)', icon: Icons.inventory_2),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () {
                if (vNameCtrl.text.isNotEmpty && vPriceCtrl.text.isNotEmpty) {
                  final pDouble = double.tryParse(vPriceCtrl.text) ?? 0;
                  final cDouble = double.tryParse(vCostCtrl.text) ?? 0;
                  setState(() {
                    _variants.add(ItemVariantEntity(
                      itemId: widget.item?.id ?? 0, // سيتم تحديثه في طبقة البيانات
                      name: vNameCtrl.text.trim(),
                      price: pDouble.toCents(),
                      costPrice: cDouble.toCents(),
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إضافة المقاس', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdownCategory(),
                  const SizedBox(height: 20),
                  _buildTextInput(
                    controller: _nameController,
                    label: 'اسم الصنف الأساسي',
                    icon: Icons.restaurant_menu,
                    validatorMsg: 'يرجى إدخال اسم الصنف',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _costPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration(label: 'التكلفة الأساسية', icon: Icons.inventory_2_outlined),
                          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration(label: 'السعر الأساسي', icon: Icons.attach_money),
                          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 🚀 قسم إدارة المقاسات
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المقاسات (اختياري)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            TextButton.icon(
                              onPressed: _showAddVariantDialog,
                              icon: const Icon(Icons.add_circle),
                              label: const Text('إضافة مقاس'),
                            )
                          ],
                        ),
                        if (_variants.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _variants.length,
                            itemBuilder: (ctx, i) {
                              final v = _variants[i];
                              return Card(
                                elevation: 0,
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('السعر: ${v.price.toFormattedMoney(currency: "ج.م")} | التكلفة: ${v.costPrice.toFormattedMoney()}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => setState(() => _variants.removeAt(i)),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          _DialogActions(onCancel: () => Navigator.pop(context), onSubmit: _onSubmit),
        ],
      ),
    );
  }

  // ==========================================
  // 🪄 مكونات واجهة الإدخال المساعدة
  // ==========================================

  Widget _buildDropdownCategory() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: _inputDecoration(label: 'القسم (الفئة)', icon: Icons.category),
      items: widget.categories.map((c) {
        return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)));
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedCategoryId = val);
      },
    );
  }

  Widget _buildTextInput({required TextEditingController controller, required String label, required IconData icon, required String validatorMsg}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: _inputDecoration(label: label, icon: icon),
      validator: (value) => (value == null || value.trim().isEmpty) ? validatorMsg : null,
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w600),
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

class _DialogHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DialogHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('حفظ البيانات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}