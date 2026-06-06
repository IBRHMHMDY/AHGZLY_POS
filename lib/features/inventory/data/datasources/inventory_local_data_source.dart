import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/inventory/data/models/inventory_item_model.dart';
import 'package:ahgzly_pos/features/inventory/data/models/recipe_model.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_with_details_entity.dart';
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

  // 🛠️ دالة مساعدة داخلية لحساب التكلفة باستخدام الـ DAO
  Future<void> _recalculateCostsForInventoryItem(int inventoryItemId) async {
    final recipes = await appDatabase.inventoryDao.getRecipesByInventoryItemId(inventoryItemId);
    final itemIds = <int>{};
    final variantIds = <int>{};
    final addonIds = <int>{};

    for (var recipe in recipes) {
      if (recipe.itemId != null) itemIds.add(recipe.itemId!);
      if (recipe.variantId != null) variantIds.add(recipe.variantId!);
      if (recipe.addonId != null) addonIds.add(recipe.addonId!);
    }

    for (var id in itemIds) {
      final newCost = await appDatabase.inventoryDao.calculateTotalCostForTarget(itemId: id);
      await appDatabase.inventoryDao.updateItemCost(id, newCost);
    }
    for (var id in variantIds) {
      final newCost = await appDatabase.inventoryDao.calculateTotalCostForTarget(variantId: id);
      await appDatabase.inventoryDao.updateVariantCost(id, newCost);
    }
    for (var id in addonIds) {
      final newCost = await appDatabase.inventoryDao.calculateTotalCostForTarget(addonId: id);
      await appDatabase.inventoryDao.updateAddonCost(id, newCost);
    }
  }

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
      return await appDatabase.transaction(() async {
        await appDatabase.update(appDatabase.inventoryItems).replace(item);
        final data = await (appDatabase.select(appDatabase.inventoryItems)..where((t) => t.id.equals(item.id.value))).getSingle();
        
        await _recalculateCostsForInventoryItem(data.id); // 🚀 الـ Costing الجديد
        
        return InventoryItemModel.fromDrift(data);
      });
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
      return {'items': items, 'variants': variants, 'addons': addons};
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
      return await appDatabase.transaction(() async {
        final id = await appDatabase.into(appDatabase.recipes).insert(recipe);
        final data = await (appDatabase.select(appDatabase.recipes)..where((t) => t.id.equals(id))).getSingle();

        // 🚀 الـ Costing الجديد للصنف بمجرد إضافة مقدار له
        if (data.itemId != null) {
          final cost = await appDatabase.inventoryDao.calculateTotalCostForTarget(itemId: data.itemId!);
          await appDatabase.inventoryDao.updateItemCost(data.itemId!, cost);
        }
        if (data.variantId != null) {
          final cost = await appDatabase.inventoryDao.calculateTotalCostForTarget(variantId: data.variantId!);
          await appDatabase.inventoryDao.updateVariantCost(data.variantId!, cost);
        }
        if (data.addonId != null) {
          final cost = await appDatabase.inventoryDao.calculateTotalCostForTarget(addonId: data.addonId!);
          await appDatabase.inventoryDao.updateAddonCost(data.addonId!, cost);
        }

        return RecipeModel.fromDrift(data);
      });
    } catch (e) {
      throw CacheException('فشل في ربط المقدار: $e');
    }
  }

  @override
  Future<void> deleteRecipe(int id) async {
    try {
      await appDatabase.transaction(() async {
        final recipeToDelete = await (appDatabase.select(appDatabase.recipes)..where((t) => t.id.equals(id))).getSingleOrNull();
        
        await (appDatabase.delete(appDatabase.recipes)..where((t) => t.id.equals(id))).go();

        if (recipeToDelete != null) {
          // 🚀 الـ Costing الجديد لإعادة الحساب بعد الحذف
          if (recipeToDelete.itemId != null) {
            final cost = await appDatabase.inventoryDao.calculateTotalCostForTarget(itemId: recipeToDelete.itemId!);
            await appDatabase.inventoryDao.updateItemCost(recipeToDelete.itemId!, cost);
          }
          if (recipeToDelete.variantId != null) {
            final cost = await appDatabase.inventoryDao.calculateTotalCostForTarget(variantId: recipeToDelete.variantId!);
            await appDatabase.inventoryDao.updateVariantCost(recipeToDelete.variantId!, cost);
          }
          if (recipeToDelete.addonId != null) {
            final cost = await appDatabase.inventoryDao.calculateTotalCostForTarget(addonId: recipeToDelete.addonId!);
            await appDatabase.inventoryDao.updateAddonCost(recipeToDelete.addonId!, cost);
          }
        }
      });
    } catch (e) {
      throw CacheException('فشل في حذف المقدار: $e');
    }
  }
}