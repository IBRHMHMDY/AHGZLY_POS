import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_variant_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/addon_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';

class ModifiersDialog extends StatefulWidget {
  final ItemEntity item;

  const ModifiersDialog({super.key, required this.item});

  @override
  State<ModifiersDialog> createState() => _ModifiersDialogState();
}

class _ModifiersDialogState extends State<ModifiersDialog> {
  ItemVariantEntity? _selectedVariant;
  final List<AddonEntity> _selectedAddons = [];
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // اختيار أول مقاس افتراضياً إذا كان الصنف يحتوي على مقاسات
    if (widget.item.variants.isNotEmpty) {
      _selectedVariant = widget.item.variants.first;
    }
  }

  // 🪄 حساب الإجمالي اللحظي داخل النافذة بناءً على الاختيارات
  int get _currentTotalPrice {
    int basePrice = _selectedVariant?.price ?? widget.item.price;
    int addonsPrice = _selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (basePrice + addonsPrice) * _quantity;
  }

  void _onAddToCart() {
    final orderItem = OrderItemEntity(
      itemId: widget.item.id!,
      itemName: widget.item.name,
      quantity: _quantity,
      unitPrice: _selectedVariant?.price ?? widget.item.price,
      unitCostPrice: _selectedVariant?.costPrice ?? widget.item.costPrice,
      selectedVariant: _selectedVariant,
      selectedAddons: List.from(_selectedAddons),
    );

    context.read<PosBloc>().add(AddItemToCartEvent(orderItem));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('تخصيص: ${widget.item.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4, // عرض مناسب لشاشات الكاشير
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. قسم المقاسات (Variants)
              if (widget.item.variants.isNotEmpty) ...[
                const Text('اختر المقاس:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: widget.item.variants.map((variant) {
                    final isSelected = _selectedVariant?.id == variant.id;
                    return ChoiceChip(
                      label: Text('${variant.name} (${variant.price.toFormattedMoney()})'),
                      selected: isSelected,
                      selectedColor: Colors.teal.withOpacity(0.2),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedVariant = variant);
                      },
                    );
                  }).toList(),
                ),
                const Divider(height: 32),
              ],

              // 2. قسم الإضافات (Addons)
              if (widget.item.availableAddons.isNotEmpty) ...[
                const Text('الإضافات:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...widget.item.availableAddons.map((addon) {
                  final isSelected = _selectedAddons.contains(addon);
                  return CheckboxListTile(
                    title: Text('${addon.name} (+${addon.price.toFormattedMoney()})'),
                    value: isSelected,
                    activeColor: Colors.teal,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedAddons.add(addon);
                        } else {
                          _selectedAddons.remove(addon);
                        }
                      });
                    },
                  );
                }),
                const Divider(height: 32),
              ],

              // 3. قسم الكمية (Quantity)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الكمية:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.shopping_cart),
          label: Text('إضافة (${_currentTotalPrice.toFormattedMoney()})', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: _onAddToCart,
        ),
      ],
    );
  }
}