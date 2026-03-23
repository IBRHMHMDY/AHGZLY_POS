import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_event.dart';
import 'package:ahgzly_pos/features/menu/presentation/bloc/menu_state.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Category? _selectedCategory;
  List<Category> _categories = [];
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة قائمة الطعام', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        // استخدمنا BlocConsumer واحد فقط يدير الشاشة بالكامل بذكاء
        child: BlocConsumer<MenuBloc, MenuState>(
          listener: (context, state) {
            if (state is CategoriesLoaded) {
              setState(() {
                _categories = state.categories;
                // اختيار أول فئة تلقائياً
                if (_selectedCategory == null && _categories.isNotEmpty) {
                  _selectedCategory = _categories.first;
                  context.read<MenuBloc>().add(FetchItemsEvent(_selectedCategory!.id!));
                } 
                // إذا تم حذف الفئة المحددة حالياً، ننتقل للأولى
                else if (_selectedCategory != null && !_categories.any((c) => c.id == _selectedCategory!.id)) {
                  _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
                  if (_selectedCategory != null) {
                    context.read<MenuBloc>().add(FetchItemsEvent(_selectedCategory!.id!));
                  } else {
                    _items = [];
                  }
                }
              });
            } else if (state is ItemsLoaded) {
              setState(() {
                _items = state.items;
              });
            } else if (state is MenuOperationSuccess) {
              // إظهار رسالة النجاح
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              // الأهم: إعادة تحميل البيانات فوراً بعد الإضافة/التعديل/الحذف لإنهاء التحميل
              context.read<MenuBloc>().add(FetchCategoriesEvent());
              if (_selectedCategory != null) {
                context.read<MenuBloc>().add(FetchItemsEvent(_selectedCategory!.id!));
              }
            } else if (state is MenuError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Row(
              children: [
                // ===================================
                // قسم الفئات (Categories)
                // ===================================
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey.shade100,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة فئة'),
                            onPressed: () => _showCategoryDialog(context),
                          ),
                        ),
                        Expanded(
                          child: state is MenuLoading && _categories.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    final isSelected = _selectedCategory?.id == category.id;

                                    return ListTile(
                                      selected: isSelected,
                                      selectedTileColor: Colors.teal.shade100,
                                      title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                            onPressed: () => _showCategoryDialog(context, category: category),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                            onPressed: () => _confirmDelete(context, 'الفئة', () {
                                              context.read<MenuBloc>().add(DeleteCategoryEvent(category.id!));
                                            }),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = category;
                                          _items = []; // تصفير الأصناف حتى يتم جلب أصناف الفئة الجديدة
                                        });
                                        context.read<MenuBloc>().add(FetchItemsEvent(category.id!));
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                // ===================================
                // قسم الأصناف (Items)
                // ===================================
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة صنف جديد'),
                          onPressed: _selectedCategory == null ? null : () => _showItemDialog(context),
                        ),
                      ),
                      Expanded(
                        child: state is MenuLoading && _items.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : _items.isEmpty
                                ? const Center(child: Text('لا توجد أصناف في هذه الفئة', style: TextStyle(fontSize: 18)))
                                : ListView.builder(
                                    itemCount: _items.length,
                                    itemBuilder: (context, index) {
                                      final item = _items[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: ListTile(
                                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Text('${item.price} ج.م', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blue),
                                                onPressed: () => _showItemDialog(context, item: item),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _confirmDelete(context, 'الصنف', () {
                                                  context.read<MenuBloc>().add(DeleteItemEvent(item.id!));
                                                }),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('حذف $title', style: const TextStyle(color: Colors.red)),
          content: Text('هل أنت متأكد من حذف $title؟ هذا الإجراء لا يمكن التراجع عنه.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                onConfirm();
                Navigator.pop(ctx);
              },
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final menuBloc = context.read<MenuBloc>(); 
    final nameController = TextEditingController(text: category?.name ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(category == null ? 'إضافة فئة' : 'تعديل فئة'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'اسم الفئة'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final now = DateTime.now().toIso8601String();
                  if (category == null) {
                    menuBloc.add(AddCategoryEvent(Category(
                      name: nameController.text,
                      createdAt: now,
                      updatedAt: now,
                    )));
                  } else {
                    menuBloc.add(UpdateCategoryEvent(Category(
                      id: category.id, 
                      name: nameController.text,
                      createdAt: category.createdAt,
                      updatedAt: now,
                    )));
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDialog(BuildContext context, {Item? item}) {
    final menuBloc = context.read<MenuBloc>();
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    int selectedCategoryId = item?.categoryId ?? _selectedCategory!.id!;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder( 
          builder: (contextDialog, setStateDialog) {
            return AlertDialog(
              title: Text(item == null ? 'إضافة صنف' : 'تعديل ونقل صنف'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'اسم الصنف'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'السعر (ج.م)'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'الفئة'),
                    items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() {
                          selectedCategoryId = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                      final price = double.parse(priceController.text);
                      final now = DateTime.now().toIso8601String(); 
                      
                      if (item == null) {
                        menuBloc.add(AddItemEvent(Item(
                          categoryId: selectedCategoryId,
                          name: nameController.text,
                          price: price,
                          createdAt: now,
                          updatedAt: now,
                        )));
                      } else {
                        menuBloc.add(UpdateItemEvent(Item(
                          id: item.id,
                          categoryId: selectedCategoryId, 
                          name: nameController.text,
                          price: price,
                          createdAt: item.createdAt, 
                          updatedAt: now, 
                        )));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}