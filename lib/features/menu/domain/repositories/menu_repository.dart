import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:dartz/dartz.dart';


abstract class MenuRepository {
  // Categories
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, int>> addCategory(CategoryEntity category);
  Future<Either<Failure, int>> updateCategory(CategoryEntity category);
  Future<Either<Failure, int>> deleteCategory(int id);

  // Items
  Future<Either<Failure, List<ItemEntity>>> getItems(int categoryId);
  Future<Either<Failure, int>> addItem(ItemEntity item);
  Future<Either<Failure, int>> updateItem(ItemEntity item);
  Future<Either<Failure, int>> deleteItem(int id);
}