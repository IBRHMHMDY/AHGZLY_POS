import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';

class ItemsSection extends StatelessWidget {
  final List<Item> items;
  final String categoryName;
  final bool isLoading;

  const ItemsSection({
    super.key,
    required this.items,
    required this.categoryName,
    required this.isLoading,
  });

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
                        // 🪄 السحر هنا: زيادة الارتفاع قليلاً لحماية النصوص عند تصغير الشاشة
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
                            onTap: () => context.read<PosBloc>().add(AddItemToCartEvent(item)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.teal.shade50,
                                    // تصغير الأيقونة قليلاً لتوفير المساحة
                                    child: Center(child: Icon(Icons.restaurant, size: 36, color: Colors.teal.shade200)),
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  // تقليل الـ Padding لتوفير مساحة للنص
                                  padding: const EdgeInsets.all(8.0), 
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min, // حماية من التمدد العمودي
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
                                        '${MoneyFormatter.format(item.price)} ج.م', 
                                        style: const TextStyle(fontSize: 15, color: Colors.teal, fontWeight: FontWeight.w900),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis, // حماية السعر من الـ Overflow
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