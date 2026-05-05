import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/inventory_item_entity.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_with_details_entity.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<InventoryItemEntity>>> getInventoryItems();
  Future<Either<Failure, InventoryItemEntity>> addInventoryItem(InventoryItemsCompanion item);
  Future<Either<Failure, InventoryItemEntity>> updateInventoryItem(InventoryItemsCompanion item);
  Future<Either<Failure, void>> deleteInventoryItem(int id);

  Future<Either<Failure, Map<String, List<dynamic>>>> getAllMenuEntities();
  Future<Either<Failure, List<RecipeWithDetailsEntity>>> getRecipes();
  Future<Either<Failure, RecipeEntity>> addRecipe(RecipesCompanion recipe);
  Future<Either<Failure, void>> deleteRecipe(int id);
}
