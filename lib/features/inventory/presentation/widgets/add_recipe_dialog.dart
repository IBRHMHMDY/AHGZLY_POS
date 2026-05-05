import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ahgzly_pos/core/database/app_database.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../../domain/entities/inventory_item_entity.dart';

class AddRecipeDialog extends StatefulWidget {
  final List<InventoryItemEntity> inventoryItems;
  final Map<String, List<dynamic>> menuEntities;

  const AddRecipeDialog({
    super.key,
    required this.inventoryItems,
    required this.menuEntities,
  });

  @override
  State<AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<AddRecipeDialog> {
  final _formKey = GlobalKey<FormState>();
  
  InventoryItemEntity? _selectedInventoryItem;
  String _selectedEntityType = 'item'; // 'item', 'variant', 'addon'
  dynamic _selectedMenuEntity;
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedInventoryItem != null && _selectedMenuEntity != null) {
      int? itemId;
      int? variantId;
      int? addonId;

      if (_selectedEntityType == 'item') itemId = _selectedMenuEntity.id;
      if (_selectedEntityType == 'variant') variantId = _selectedMenuEntity.id;
      if (_selectedEntityType == 'addon') addonId = _selectedMenuEntity.id;

      final recipe = RecipesCompanion.insert(
        itemId: drift.Value(itemId),
        variantId: drift.Value(variantId),
        addonId: drift.Value(addonId),
        inventoryItemId: _selectedInventoryItem!.id,
        quantityNeeded: double.parse(_quantityController.text.trim()),
      );

      context.read<InventoryBloc>().add(AddRecipeEvent(recipe));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> entitiesList = [];
    if (_selectedEntityType == 'item') entitiesList = widget.menuEntities['items'] ?? [];
    if (_selectedEntityType == 'variant') entitiesList = widget.menuEntities['variants'] ?? [];
    if (_selectedEntityType == 'addon') entitiesList = widget.menuEntities['addons'] ?? [];

    return AlertDialog(
      title: const Text('ربط مقدار بصنف'),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. نوع الهدف
              DropdownButtonFormField<String>(
                value: _selectedEntityType,
                decoration: const InputDecoration(labelText: 'نوع الصنف بالمنيو', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'item', child: Text('صنف رئيسي (وجبة)')),
                  DropdownMenuItem(value: 'variant', child: Text('حجم / مقاس')),
                  DropdownMenuItem(value: 'addon', child: Text('إضافة (Addon)')),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedEntityType = val!;
                    _selectedMenuEntity = null; // Reset selection
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 2. الهدف
              DropdownButtonFormField<dynamic>(
                value: _selectedMenuEntity,
                decoration: const InputDecoration(labelText: 'اختر الصنف / الحجم / الإضافة', border: OutlineInputBorder()),
                items: entitiesList.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (val) => setState(() => _selectedMenuEntity = val),
                validator: (val) => val == null ? 'يرجى اختيار الهدف' : null,
              ),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 16),

              // 3. الخامة
              DropdownButtonFormField<InventoryItemEntity>(
                value: _selectedInventoryItem,
                decoration: const InputDecoration(labelText: 'اختر الخامة المراد خصمها', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2)),
                items: widget.inventoryItems.map((e) => DropdownMenuItem(value: e, child: Text('${e.name} (${e.unit})'))).toList(),
                onChanged: (val) => setState(() => _selectedInventoryItem = val),
                validator: (val) => val == null ? 'يرجى اختيار خامة' : null,
              ),
              const SizedBox(height: 16),

              // 4. الكمية
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'الكمية المستهلكة (بـ ${_selectedInventoryItem?.unit ?? 'الوحدة'})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.scale),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'مطلوب';
                  if (double.tryParse(val) == null) return 'أدخل رقماً صحيحاً';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          onPressed: _submit,
          child: const Text('حفظ المقدار'),
        ),
      ],
    );
  }
}
