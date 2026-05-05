import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_entity.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    super.itemId,
    super.variantId,
    super.addonId,
    required super.inventoryItemId,
    required super.quantityNeeded,
  });

  factory RecipeModel.fromDrift(RecipeData data) {
    return RecipeModel(
      id: data.id,
      itemId: data.itemId,
      variantId: data.variantId,
      addonId: data.addonId,
      inventoryItemId: data.inventoryItemId,
      quantityNeeded: data.quantityNeeded,
    );
  }
}
