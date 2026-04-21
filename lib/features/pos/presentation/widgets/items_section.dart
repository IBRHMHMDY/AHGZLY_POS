import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_variant_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/addon_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';

class ItemsSection extends StatelessWidget {
  final List<ItemEntity> items;
  final String categoryName;
  final bool isLoading;

  const ItemsSection({
    super.key,
    required this.items,
    required this.categoryName,
    required this.isLoading,
  });

  // 🚀 دالة معالجة إضافة الصنف
  void _onItemTap(BuildContext context, ItemEntity item) {
    // إذا كان الصنف يحتوي على مقاسات أو إضافات، نعرض نافذة الاختيار
    if (item.variants.isNotEmpty || item.availableAddons.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => _ItemModifierDialog(item: item),
      );
    } else {
      // إذا كان صنفاً عادياً، تتم إضافته مباشرة
      final orderItem = OrderItemEntity(
        itemId: item.id!,
        itemName: item.name,
        quantity: 1,
        unitPrice: item.price,
        unitCostPrice: item.costPrice,
      );
      context.read<PosBloc>().add(AddItemToCartEvent(orderItem));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(categoryName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Expanded(
          child: isLoading && items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood_outlined, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('لا توجد أصناف في هذا القسم', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.75, 
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          elevation: 2,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _onItemTap(context, item),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.teal.shade50,
                                    child: Center(child: Icon(Icons.restaurant, size: 36, color: Colors.teal.shade200)),
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(8.0), 
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min, 
                                    children: [
                                      Text(
                                        item.name, 
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), 
                                        maxLines: 2, 
                                        textAlign: TextAlign.center, 
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.price.toFormattedMoney()} ج.م', 
                                        style: const TextStyle(fontSize: 15, color: Colors.teal, fontWeight: FontWeight.w900),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ==========================================
// 🪄 نافذة المقاسات والإضافات (Modifier Dialog)
// ==========================================
class _ItemModifierDialog extends StatefulWidget {
  final ItemEntity item;

  const _ItemModifierDialog({required this.item});

  @override
  State<_ItemModifierDialog> createState() => _ItemModifierDialogState();
}

class _ItemModifierDialogState extends State<_ItemModifierDialog> {
  ItemVariantEntity? _selectedVariant;
  final List<AddonEntity> _selectedAddons = [];
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // إذا كان هناك مقاسات، اختر الأول كافتراضي
    if (widget.item.variants.isNotEmpty) {
      _selectedVariant = widget.item.variants.first;
    }
  }

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(widget.item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. قسم المقاسات (Variants)
                if (widget.item.variants.isNotEmpty) ...[
                  const Text('اختر المقاس:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...widget.item.variants.map((variant) => RadioListTile<ItemVariantEntity>(
                    title: Text(variant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${variant.price.toFormattedMoney()} ج.م', style: const TextStyle(color: Colors.teal)),
                    value: variant,
                    groupValue: _selectedVariant,
                    activeColor: Colors.teal,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _selectedVariant = val),
                  )),
                  const Divider(),
                ],

                // 2. قسم الإضافات (Addons)
                if (widget.item.availableAddons.isNotEmpty) ...[
                  const Text('الإضافات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...widget.item.availableAddons.map((addon) {
                    final isSelected = _selectedAddons.contains(addon);
                    return CheckboxListTile(
                      title: Text(addon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('+ ${addon.price.toFormattedMoney()} ج.م', style: const TextStyle(color: Colors.teal)),
                      value: isSelected,
                      activeColor: Colors.teal,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedAddons.add(addon);
                          } else {
                            _selectedAddons.remove(addon);
                          }
                        });
                      },
                    );
                  }),
                  const Divider(),
                ],

                // 3. التحكم بالكمية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الكمية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.shopping_cart),
            label: Text('إضافة (${_currentTotalPrice.toFormattedMoney()} ج.م)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: _onAddToCart,
          ),
        ],
      ),
    );
  }
}