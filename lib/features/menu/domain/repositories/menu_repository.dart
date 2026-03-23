import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:dartz/dartz.dart';


abstract class MenuRepository {
  // Categories
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, int>> addCategory(Category category);
  Future<Either<Failure, int>> updateCategory(Category category);
  Future<Either<Failure, int>> deleteCategory(int id);

  // Items
  Future<Either<Failure, List<Item>>> getItems(int categoryId);
  Future<Either<Failure, int>> addItem(Item item);
  Future<Either<Failure, int>> updateItem(Item item);
  Future<Either<Failure, int>> deleteItem(int id);
}