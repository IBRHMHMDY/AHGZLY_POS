import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_state.dart';
import 'package:ahgzly_pos/features/menu/presentation/widgets/category_dialog.dart';
import 'package:ahgzly_pos/features/menu/presentation/widgets/item_dialog.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  Category? _selectedCategory;
  List<Category> _categories = [];
  List<Item> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة القائمة (المنيو)'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<MenuBloc, MenuState>(
          listener: (context, state) {
            if (state is MenuOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<MenuBloc>().add(FetchCategoriesEvent());
              if (_selectedCategory != null) {
                context.read<MenuBloc>().add(
                  FetchItemsEvent(_selectedCategory!.id!),
                );
              }
            } else if (state is MenuError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is CategoriesLoaded) {
              setState(() {
                _categories = state.categories;
                if (_selectedCategory == null && _categories.isNotEmpty) {
                  _selectedCategory = _categories.first;
                  context.read<MenuBloc>().add(
                    FetchItemsEvent(_selectedCategory!.id!),
                  );
                }
              });
            } else if (state is ItemsLoaded) {
              setState(() {
                _items = state.items;
              });
            }
          },
          builder: (context, state) {
            return Row(
              children: [
                // الجانب الأيمن: الفئات
                Expanded(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text(
                            'الفئات',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.teal,
                            ),
                            onPressed: () async {
                              final Category? result = await showDialog(
                                context: context,
                                builder: (_) => const CategoryDialog(),
                              );
                              // تم تعديل mounted إلى context.mounted
                              if (result != null && context.mounted) {
                                context.read<MenuBloc>().add(
                                  AddCategoryEvent(result),
                                );
                              }
                            },
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: _categories.isEmpty
                              ? const Center(child: Text('لا توجد فئات'))
                              : ListView.builder(
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    final isSelected =
                                        _selectedCategory?.id == category.id;
                                    return ListTile(
                                      title: Text(category.name),
                                      selected: isSelected,
                                      selectedTileColor: Colors.teal
                                          .withOpacity(0.1),
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                        context.read<MenuBloc>().add(
                                          FetchItemsEvent(category.id!),
                                        );
                                      },
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              final Category? result =
                                                  await showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        CategoryDialog(
                                                          category: category,
                                                        ),
                                                  );
                                              // تم تعديل mounted إلى context.mounted
                                              if (result != null &&
                                                  context.mounted) {
                                                context.read<MenuBloc>().add(
                                                  UpdateCategoryEvent(result),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // الجانب الأيسر: الأصناف
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            _selectedCategory == null
                                ? 'الأصناف'
                                : 'أصناف (${_selectedCategory!.name})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.teal,
                            ),
                            onPressed: _selectedCategory == null
                                ? null
                                : () async {
                                    final Item? result = await showDialog(
                                      context: context,
                                      builder: (_) => ItemDialog(
                                        categoryId: _selectedCategory!.id!,
                                      ),
                                    );
                                    // تم تعديل mounted إلى context.mounted
                                    if (result != null && context.mounted) {
                                      context.read<MenuBloc>().add(
                                        AddItemEvent(result),
                                      );
                                    }
                                  },
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: state is MenuLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _selectedCategory == null
                              ? const Center(
                                  child: Text('يرجى اختيار فئة لعرض الأصناف'),
                                )
                              : _items.isEmpty
                              ? const Center(
                                  child: Text('لا توجد أصناف في هذه الفئة'),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1.5,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemCount: _items.length,
                                  itemBuilder: (context, index) {
                                    final item = _items[index];
                                    return Card(
                                      color: Colors.teal.shade50,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${item.price} ج.م',
                                                  style: const TextStyle(
                                                    color: Colors.teal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 18,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () async {
                                                final Item?
                                                result = await showDialog(
                                                  context: context,
                                                  builder: (_) => ItemDialog(
                                                    item: item,
                                                    categoryId:
                                                        _selectedCategory!.id!,
                                                  ),
                                                );
                                                // تم تعديل mounted إلى context.mounted
                                                if (result != null &&
                                                    context.mounted) {
                                                  context.read<MenuBloc>().add(
                                                    UpdateItemEvent(result),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
