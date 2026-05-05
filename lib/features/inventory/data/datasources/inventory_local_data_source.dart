import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/inventory/data/models/inventory_item_model.dart';
import 'package:ahgzly_pos/features/inventory/data/models/recipe_model.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_with_details_entity.dart';
import 'package:ahgzly_pos/core/database/costing_helper.dart';
import 'package:drift/drift.dart';

abstract class InventoryLocalDataSource {
  Future<List<InventoryItemModel>> getInventoryItems();
  Future<InventoryItemModel> addInventoryItem(InventoryItemsCompanion item);
  Future<InventoryItemModel> updateInventoryItem(InventoryItemsCompanion item);
  Future<void> deleteInventoryItem(int id);

  Future<Map<String, List<dynamic>>> getAllMenuEntities();
  Future<List<RecipeWithDetailsEntity>> getRecipes();
  Future<RecipeModel> addRecipe(RecipesCompanion recipe);
  Future<void> deleteRecipe(int id);
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final AppDatabase appDatabase;

  InventoryLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<List<InventoryItemModel>> getInventoryItems() async {
    try {
      final items = await appDatabase.select(appDatabase.inventoryItems).get();
      return items.map((i) => InventoryItemModel.fromDrift(i)).toList();
    } catch (e) {
      throw CacheException('فشل في جلب الخامات: $e');
    }
  }

  @override
  Future<InventoryItemModel> addInventoryItem(InventoryItemsCompanion item) async {
    try {
      final id = await appDatabase.into(appDatabase.inventoryItems).insert(item);
      final data = await (appDatabase.select(appDatabase.inventoryItems)..where((t) => t.id.equals(id))).getSingle();
      return InventoryItemModel.fromDrift(data);
    } catch (e) {
      throw CacheException('فشل في إضافة الخامة: $e');
    }
  }

  @override
  Future<InventoryItemModel> updateInventoryItem(InventoryItemsCompanion item) async {
    try {
      await appDatabase.update(appDatabase.inventoryItems).replace(item);
      final data = await (appDatabase.select(appDatabase.inventoryItems)..where((t) => t.id.equals(item.id.value))).getSingle();
      return InventoryItemModel.fromDrift(data);
    } catch (e) {
      throw CacheException('فشل في تحديث الخامة: $e');
    }
  }

  @override
  Future<void> deleteInventoryItem(int id) async {
    try {
      await (appDatabase.delete(appDatabase.inventoryItems)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw CacheException('فشل في حذف الخامة، قد تكون مستخدمة في وصفة أو حركة مخزنية.');
    }
  }

  @override
  Future<Map<String, List<dynamic>>> getAllMenuEntities() async {
    try {
      final items = await appDatabase.select(appDatabase.items).get();
      final variants = await appDatabase.select(appDatabase.itemVariants).get();
      final addons = await appDatabase.select(appDatabase.addons).get();
      return {
        'items': items,
        'variants': variants,
        'addons': addons,
      };
    } catch (e) {
      throw CacheException('فشل في جلب قائمة المنيو: $e');
    }
  }

  @override
  Future<List<RecipeWithDetailsEntity>> getRecipes() async {
    try {
      final query = appDatabase.select(appDatabase.recipes).join([
        leftOuterJoin(appDatabase.items, appDatabase.items.id.equalsExp(appDatabase.recipes.itemId)),
        leftOuterJoin(appDatabase.itemVariants, appDatabase.itemVariants.id.equalsExp(appDatabase.recipes.variantId)),
        leftOuterJoin(appDatabase.addons, appDatabase.addons.id.equalsExp(appDatabase.recipes.addonId)),
        innerJoin(appDatabase.inventoryItems, appDatabase.inventoryItems.id.equalsExp(appDatabase.recipes.inventoryItemId)),
      ]);

      final results = await query.get();

      return results.map((row) {
        final recipe = row.readTable(appDatabase.recipes);
        final item = row.readTableOrNull(appDatabase.items);
        final variant = row.readTableOrNull(appDatabase.itemVariants);
        final addon = row.readTableOrNull(appDatabase.addons);
        final invItem = row.readTable(appDatabase.inventoryItems);

        return RecipeWithDetailsEntity(
          id: recipe.id,
          itemId: recipe.itemId,
          itemName: item?.name,
          variantId: recipe.variantId,
          variantName: variant?.name,
          addonId: recipe.addonId,
          addonName: addon?.name,
          inventoryItemId: recipe.inventoryItemId,
          inventoryItemName: invItem.name,
          unit: invItem.unit,
          quantityNeeded: recipe.quantityNeeded,
        );
      }).toList();
    } catch (e) {
      throw CacheException('فشل في جلب المقادير: $e');
    }
  }

  @override
  Future<RecipeModel> addRecipe(RecipesCompanion recipe) async {
    try {
      final id = await appDatabase.into(appDatabase.recipes).insert(recipe);
      final data = await (appDatabase.select(appDatabase.recipes)..where((t) => t.id.equals(id))).getSingle();

      // [Costing] Recalculate cost for the target menu item
      final costingHelper = CostingHelper(appDatabase);
      if (data.itemId != null) await costingHelper.recalculateCostForItem(data.itemId!);
      if (data.variantId != null) await costingHelper.recalculateCostForVariant(data.variantId!);
      if (data.addonId != null) await costingHelper.recalculateCostForAddon(data.addonId!);

      return RecipeModel.fromDrift(data);
    } catch (e) {
      throw CacheException('فشل في ربط المقدار: $e');
    }
  }

  @override
  Future<void> deleteRecipe(int id) async {
    try {
      final recipeToDelete = await (appDatabase.select(appDatabase.recipes)..where((t) => t.id.equals(id))).getSingleOrNull();
      
      await (appDatabase.delete(appDatabase.recipes)..where((t) => t.id.equals(id))).go();

      // [Costing] Recalculate cost for the target menu item after deleting recipe
      if (recipeToDelete != null) {
        final costingHelper = CostingHelper(appDatabase);
        if (recipeToDelete.itemId != null) await costingHelper.recalculateCostForItem(recipeToDelete.itemId!);
        if (recipeToDelete.variantId != null) await costingHelper.recalculateCostForVariant(recipeToDelete.variantId!);
        if (recipeToDelete.addonId != null) await costingHelper.recalculateCostForAddon(recipeToDelete.addonId!);
      }
    } catch (e) {
      throw CacheException('فشل في حذف المقدار: $e');
    }
  }
}
