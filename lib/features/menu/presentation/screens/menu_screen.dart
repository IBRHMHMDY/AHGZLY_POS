import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_state.dart';
import 'package:ahgzly_pos/features/menu/presentation/widgets/category_dialog.dart';
import 'package:ahgzly_pos/features/menu/presentation/widgets/item_dialog.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/core/common/widgets/custom_shimmer.dart'; // 🪄 استيراد مكون الشيمر

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  CategoryEntity? _selectedCategory;
  List<CategoryEntity> _categories = [];
  List<ItemEntity> _items = [];

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchCategoriesEvent());
  }

  void _handleCategoryAction(CategoryEntity? existingCategory) async {
    final result = await showDialog<CategoryEntity>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CategoryDialog(category: existingCategory),
    );

    if (result != null && mounted) {
      if (existingCategory == null) {
        context.read<MenuBloc>().add(AddCategoryEvent(result));
      } else {
        context.read<MenuBloc>().add(UpdateCategoryEvent(result));
      }
    }
  }

  void _handleItemAction(ItemEntity? existingItem) async {
    if (_selectedCategory == null) return;
    final result = await showDialog<ItemEntity>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ItemDialog(
        item: existingItem,
        initialCategoryId: _selectedCategory!.id!,
        categories: _categories,
      ),
    );

    if (result != null && mounted) {
      if (existingItem == null) {
        context.read<MenuBloc>().add(AddItemEvent(result));
      } else {
        context.read<MenuBloc>().add(UpdateItemEvent(result));
      }
    }
  }

  void _confirmDelete(BuildContext context, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('حذف $title', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من حذف $title؟ هذا الإجراء سيحذف البيانات نهائياً.', style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontSize: 16))),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            icon: const Icon(Icons.delete_forever),
            label: const Text('تأكيد الحذف', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 8),
            Text('إدارة قائمة الطعام', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<MenuBloc, MenuState>(
        listener: (context, state) {
          if (state is CategoriesLoaded) {
            setState(() {
              _categories = state.categories;
              if (_selectedCategory == null && _categories.isNotEmpty) {
                _selectedCategory = _categories.first;
                context.read<MenuBloc>().add(FetchItemsEvent(_selectedCategory!.id!));
              } else if (_selectedCategory != null && !_categories.any((c) => c.id == _selectedCategory!.id)) {
                _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
                if (_selectedCategory != null) {
                  context.read<MenuBloc>().add(FetchItemsEvent(_selectedCategory!.id!));
                } else {
                  _items = [];
                }
              }
            });
          } else if (state is ItemsLoaded) {
            setState(() => _items = state.items);
          } else if (state is MenuOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            context.read<MenuBloc>().add(FetchCategoriesEvent());
            if (_selectedCategory != null) {
              context.read<MenuBloc>().add(FetchItemsEvent(_selectedCategory!.id!));
            }
          } else if (state is MenuError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          final isLoading = state is MenuLoading;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🪄 1. عمود الفئات (تم استخراجه لـ Widget منفصل)
              Expanded(
                flex: 1,
                child: _MenuCategoriesSection(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  isLoading: isLoading && _categories.isEmpty,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                      _items = []; // تصفير الأصناف أثناء التحميل
                    });
                    context.read<MenuBloc>().add(FetchItemsEvent(category.id!));
                  },
                  onAddCategory: () => _handleCategoryAction(null),
                  onEditCategory: (category) => _handleCategoryAction(category),
                  onDeleteCategory: (category) => _confirmDelete(context, 'الفئة', () => context.read<MenuBloc>().add(DeleteCategoryEvent(category.id!))),
                ),
              ),

              // 🪄 2. عمود الأصناف (تم استخراجه لـ Widget منفصل)
              Expanded(
                flex: 3,
                child: _MenuItemsSection(
                  items: _items,
                  selectedCategory: _selectedCategory,
                  isLoading: isLoading,
                  onAddItem: () => _handleItemAction(null),
                  onEditItem: (item) => _handleItemAction(item),
                  onDeleteItem: (item) => _confirmDelete(context, 'الصنف', () => context.read<MenuBloc>().add(DeleteItemEvent(item.id!))),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==========================================
// 🪄 المكونات الفرعية (Sub-Widgets) النظيفة
// ==========================================

class _MenuCategoriesSection extends StatelessWidget {
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final bool isLoading;
  final ValueChanged<CategoryEntity> onCategorySelected;
  final VoidCallback onAddCategory;
  final ValueChanged<CategoryEntity> onEditCategory;
  final ValueChanged<CategoryEntity> onDeleteCategory;

  const _MenuCategoriesSection({
    required this.categories,
    required this.selectedCategory,
    required this.isLoading,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.onEditCategory,
    required this.onDeleteCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.grey.shade300))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              icon: const Icon(Icons.add),
              label: const Text('إضافة فئة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: onAddCategory,
            ),
          ),
          Expanded(
            child: isLoading
                ? const _CategoriesShimmerLoading() // 🪄 استخدام الشيمر الاحترافي
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory?.id == category.id;

                      return InkWell(
                        onTap: () => onCategorySelected(category),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.teal : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? Colors.teal : Colors.grey.shade300),
                            boxShadow: isSelected ? [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: isSelected ? Colors.white70 : Colors.blue),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                                onPressed: () => onEditCategory(category),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: isSelected ? Colors.white70 : Colors.red),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                                onPressed: () => onDeleteCategory(category),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemsSection extends StatelessWidget {
  final List<ItemEntity> items;
  final CategoryEntity? selectedCategory;
  final bool isLoading;
  final VoidCallback onAddItem;
  final ValueChanged<ItemEntity> onEditItem;
  final ValueChanged<ItemEntity> onDeleteItem;

  const _MenuItemsSection({
    required this.items,
    required this.selectedCategory,
    required this.isLoading,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedCategory != null ? 'أصناف: ${selectedCategory!.name}' : 'الأصناف',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                icon: const Icon(Icons.add),
                label: const Text('إضافة صنف جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: selectedCategory == null ? null : onAddItem,
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading && items.isEmpty
              ? const _ItemsShimmerLoading() // 🪄 استخدام الشيمر لشبكة الأصناف
              : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood_outlined, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('لا توجد أصناف في هذه الفئة', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          elevation: 3,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Colors.teal.shade50,
                                      child: Center(child: Icon(Icons.restaurant, size: 48, color: Colors.teal.shade200)),
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
                                          '${MoneyFormatter.format(item.price)} ج.م',
                                          style: const TextStyle(fontSize: 18, color: Colors.teal, fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        onPressed: () => onEditItem(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        onPressed: () => onDeleteItem(item),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
// 🪄 مكونات الشيمر الخاصة بإدارة المنيو
// ==========================================

class _CategoriesShimmerLoading extends StatelessWidget {
  const _CategoriesShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: CustomShimmer.rectangular(height: 55, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      },
    );
  }
}

class _ItemsShimmerLoading extends StatelessWidget {
  const _ItemsShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return CustomShimmer.rectangular(height: double.infinity, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)));
      },
    );
  }
}