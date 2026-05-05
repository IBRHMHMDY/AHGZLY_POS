import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/inventory_item_entity.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_entity.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/recipe_with_details_entity.dart';
import 'package:ahgzly_pos/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:dartz/dartz.dart';
import '../../data/datasources/inventory_local_data_source.dart';


class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;

  InventoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<InventoryItemEntity>>> getInventoryItems() async {
    try {
      final items = await localDataSource.getInventoryItems();
      return Right(items);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, InventoryItemEntity>> addInventoryItem(InventoryItemsCompanion item) async {
    try {
      final result = await localDataSource.addInventoryItem(item);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, InventoryItemEntity>> updateInventoryItem(InventoryItemsCompanion item) async {
    try {
      final result = await localDataSource.updateInventoryItem(item);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInventoryItem(int id) async {
    try {
      await localDataSource.deleteInventoryItem(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<dynamic>>>> getAllMenuEntities() async {
    try {
      final entities = await localDataSource.getAllMenuEntities();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecipeWithDetailsEntity>>> getRecipes() async {
    try {
      final recipes = await localDataSource.getRecipes();
      return Right(recipes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> addRecipe(RecipesCompanion recipe) async {
    try {
      final result = await localDataSource.addRecipe(recipe);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecipe(int id) async {
    try {
      await localDataSource.deleteRecipe(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
