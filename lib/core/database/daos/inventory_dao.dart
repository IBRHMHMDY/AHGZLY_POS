// مسار الملف: lib/core/database/daos/inventory_dao.dart

import 'package:drift/drift.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/database/tables.dart';

part 'inventory_dao.g.dart';

@DriftAccessor(tables: [InventoryItems, Recipes, Items, ItemVariants, Addons])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.db);

  // 1. جلب المقادير المرتبطة بخامة معينة
  Future<List<RecipeData>> getRecipesByInventoryItemId(int inventoryItemId) {
    return (select(recipes)..where((t) => t.inventoryItemId.equals(inventoryItemId))).get();
  }

  // 2. حساب إجمالي التكلفة عبر الـ Joins مباشرة في قاعدة البيانات
  Future<int> calculateTotalCostForTarget({int? itemId, int? variantId, int? addonId}) async {
    final query = select(recipes).join([
      innerJoin(inventoryItems, inventoryItems.id.equalsExp(recipes.inventoryItemId)),
    ]);

    if (itemId != null) {
      query.where(recipes.itemId.equals(itemId));
    } else if (variantId != null) {
      query.where(recipes.variantId.equals(variantId));
    } else if (addonId != null) {
      query.where(recipes.addonId.equals(addonId));
    }

    final rows = await query.get();
    double totalCost = 0;

    for (var row in rows) {
      final recipe = row.readTable(recipes);
      final inventoryItem = row.readTable(inventoryItems);
      totalCost += (recipe.quantityNeeded * inventoryItem.costPerUnit);
    }

    return totalCost.round();
  }

  // 3. تحديث أسعار التكلفة
  Future<void> updateItemCost(int itemId, int newCost) {
    return (update(items)..where((t) => t.id.equals(itemId)))
        .write(ItemsCompanion(costPrice: Value(newCost)));
  }

  Future<void> updateVariantCost(int variantId, int newCost) {
    return (update(itemVariants)..where((t) => t.id.equals(variantId)))
        .write(ItemVariantsCompanion(costPrice: Value(newCost)));
  }

  Future<void> updateAddonCost(int addonId, int newCost) {
    return (update(addons)..where((t) => t.id.equals(addonId)))
        .write(AddonsCompanion(costPrice: Value(newCost)));
  }
}