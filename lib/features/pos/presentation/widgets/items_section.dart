import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/core/common/widgets/custom_shimmer.dart';

class ItemsSection extends StatelessWidget {
  final List<ItemEntity> items;
  final bool isLoading;
  final Function(ItemEntity) onItemTap;

  const ItemsSection({super.key, required this.items, required this.isLoading, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _ItemsShimmer();
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_food_rounded, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('لا توجد أصناف في هذا القسم', style: TextStyle(fontSize: 20, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      // 🚀 [FIXED]: استخدام MaxCrossAxisExtent لتتجاوب الشبكة تلقائياً مع حجم الشاشة
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200, 
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => onItemTap(item),
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: 4,
            shadowColor: Colors.teal.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.teal.shade50,
                    child: Center(child: Icon(Icons.fastfood, size: 48, color: Colors.teal.shade300)),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.price.toFormattedMoney()} ج.م',
                        style: const TextStyle(fontSize: 18, color: Colors.teal, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ItemsShimmer extends StatelessWidget {
  const _ItemsShimmer();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200, childAspectRatio: 0.85, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => CustomShimmer.rectangular(height: double.infinity, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }
}