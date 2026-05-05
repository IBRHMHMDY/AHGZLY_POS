import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_with_details_entity.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_entity.dart';
import 'package:dartz/dartz.dart';
import '../repositories/inventory_repository.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';

class GetRecipesUseCase implements UseCase<List<RecipeWithDetailsEntity>, NoParams> {
  final InventoryRepository repository;
  GetRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecipeWithDetailsEntity>>> call(NoParams params) async {
    return await repository.getRecipes();
  }
}

class GetAllMenuEntitiesUseCase implements UseCase<Map<String, List<dynamic>>, NoParams> {
  final InventoryRepository repository;
  GetAllMenuEntitiesUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, List<dynamic>>>> call(NoParams params) async {
    return await repository.getAllMenuEntities();
  }
}

class AddRecipeUseCase implements UseCase<RecipeEntity, RecipesCompanion> {
  final InventoryRepository repository;
  AddRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, RecipeEntity>> call(RecipesCompanion params) async {
    return await repository.addRecipe(params);
  }
}

class DeleteRecipeUseCase implements UseCase<void, int> {
  final InventoryRepository repository;
  DeleteRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteRecipe(id);
  }
}
