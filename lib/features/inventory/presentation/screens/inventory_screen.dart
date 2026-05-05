import 'package:ahgzly_pos/features/inventory/presentation/widgets/add_inventory_item_dialog.dart';
import 'package:ahgzly_pos/features/inventory/presentation/widgets/add_recipe_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(LoadInventoryItemsEvent());
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<InventoryBloc>(),
        child: const AddInventoryItemDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.inventory),
              SizedBox(width: 8),
              Text('المخزون والمقادير', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            tabs: [
              Tab(icon: Icon(Icons.warehouse), text: 'الخامات والمخزون'),
              Tab(icon: Icon(Icons.receipt_long), text: 'مقادير المنيو (Recipes)'),
            ],
          ),
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading || state is InventoryInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is InventoryLoaded) {
              return TabBarView(
                children: [
                  _InventoryListTab(
                    items: state.items,
                    onAddPressed: _showAddItemDialog,
                  ),
                  _RecipesListTab(
                    recipes: state.recipes,
                    inventoryItems: state.items,
                    menuEntities: state.menuEntities,
                  ),
                ],
              );
            }
            if (state is InventoryError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 18)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _InventoryListTab extends StatelessWidget {
  final List<dynamic> items;
  final VoidCallback onAddPressed;

  const _InventoryListTab({required this.items, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('لا توجد خامات في المخزن', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isLowStock = item.stockQuantity <= 5; // Alert if stock <= 5
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isLowStock ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: isLowStock ? Colors.red.shade100 : Colors.teal.shade100,
                        radius: 25,
                        child: Icon(Icons.scale, color: isLowStock ? Colors.red : Colors.teal),
                      ),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('سعر الوحدة الافتراضي: ${(item.costPerUnit / 100).toStringAsFixed(2)} ج.م'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.stockQuantity.toStringAsFixed(2)} ${item.unit}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isLowStock ? Colors.red : Colors.black87,
                            ),
                          ),
                          if (isLowStock)
                            const Text('نواقص', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton.extended(
            heroTag: 'add_inv',
            onPressed: onAddPressed,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('إضافة خامة', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _RecipesListTab extends StatelessWidget {
  final List<dynamic> recipes;
  final List<dynamic> inventoryItems;
  final Map<String, List<dynamic>> menuEntities;

  const _RecipesListTab({
    required this.recipes,
    required this.inventoryItems,
    required this.menuEntities,
  });

  void _showAddRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<InventoryBloc>(),
        child: AddRecipeDialog(
          inventoryItems: inventoryItems.cast(),
          menuEntities: menuEntities,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        recipes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('لم يتم إضافة مقادير للمنيو بعد', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  
                  String targetName = '';
                  IconData targetIcon = Icons.fastfood;
                  Color targetColor = Colors.orange;

                  if (recipe.itemName != null) {
                    targetName = 'صنف: ${recipe.itemName}';
                  } else if (recipe.variantName != null) {
                    targetName = 'حجم: ${recipe.variantName}';
                    targetIcon = Icons.format_size;
                    targetColor = Colors.blue;
                  } else if (recipe.addonName != null) {
                    targetName = 'إضافة: ${recipe.addonName}';
                    targetIcon = Icons.add_circle;
                    targetColor = Colors.purple;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: targetColor.withOpacity(0.1),
                        child: Icon(targetIcon, color: targetColor),
                      ),
                      title: Text(targetName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('يستهلك: ', style: TextStyle(color: Colors.grey.shade700)),
                            Text(
                              '${recipe.quantityNeeded} ${recipe.unit} من ${recipe.inventoryItemName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<InventoryBloc>().add(DeleteRecipeEvent(recipe.id));
                        },
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton.extended(
            heroTag: 'add_recipe',
            onPressed: () => _showAddRecipeDialog(context),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_link),
            label: const Text('ربط مقدار بوجبة', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
