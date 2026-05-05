import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:drift/drift.dart';

class CostingHelper {
  final AppDatabase db;

  CostingHelper(this.db);

  /// يُستدعى هذا التابع بعد تحديث سعر تكلفة الخامة (InventoryItem)
  /// ليقوم بالبحث عن جميع المقادير المرتبطة وتحديث تكلفة الأصناف تلقائياً.
  Future<void> recalculateCostsForInventoryItem(int inventoryItemId) async {
    // 1. إيجاد جميع المقادير التي تستخدم هذه الخامة
    final recipes = await (db.select(db.recipes)..where((t) => t.inventoryItemId.equals(inventoryItemId))).get();

    final itemIds = <int>{};
    final variantIds = <int>{};
    final addonIds = <int>{};

    for (var recipe in recipes) {
      if (recipe.itemId != null) itemIds.add(recipe.itemId!);
      if (recipe.variantId != null) variantIds.add(recipe.variantId!);
      if (recipe.addonId != null) addonIds.add(recipe.addonId!);
    }

    // 2. تحديث التكلفة لكل صنف/حجم/إضافة متأثر
    for (var id in itemIds) {
      await recalculateCostForItem(id);
    }
    for (var id in variantIds) {
      await recalculateCostForVariant(id);
    }
    for (var id in addonIds) {
      await recalculateCostForAddon(id);
    }
  }

  /// حساب التكلفة لصنف رئيسي
  Future<void> recalculateCostForItem(int itemId) async {
    final newCost = await _calculateTotalCostForTarget(itemId: itemId);
    await (db.update(db.items)..where((t) => t.id.equals(itemId))).write(ItemsCompanion(costPrice: Value(newCost)));
  }

  /// حساب التكلفة لحجم (Variant)
  Future<void> recalculateCostForVariant(int variantId) async {
    final newCost = await _calculateTotalCostForTarget(variantId: variantId);
    await (db.update(db.itemVariants)..where((t) => t.id.equals(variantId))).write(ItemVariantsCompanion(costPrice: Value(newCost)));
  }

  /// حساب التكلفة لإضافة (Addon)
  Future<void> recalculateCostForAddon(int addonId) async {
    final newCost = await _calculateTotalCostForTarget(addonId: addonId);
    await (db.update(db.addons)..where((t) => t.id.equals(addonId))).write(AddonsCompanion(costPrice: Value(newCost)));
  }

  /// دالة مساعدة لحساب الإجمالي
  Future<int> _calculateTotalCostForTarget({int? itemId, int? variantId, int? addonId}) async {
    final query = db.select(db.recipes).join([
      innerJoin(db.inventoryItems, db.inventoryItems.id.equalsExp(db.recipes.inventoryItemId)),
    ]);

    if (itemId != null) {
      query.where(db.recipes.itemId.equals(itemId));
    } else if (variantId != null) {
      query.where(db.recipes.variantId.equals(variantId));
    } else if (addonId != null) {
      query.where(db.recipes.addonId.equals(addonId));
    }

    final rows = await query.get();
    double totalCost = 0;

    for (var row in rows) {
      final recipe = row.readTable(db.recipes);
      final inventoryItem = row.readTable(db.inventoryItems);
      
      totalCost += (recipe.quantityNeeded * inventoryItem.costPerUnit);
    }

    return totalCost.round();
  }
}
