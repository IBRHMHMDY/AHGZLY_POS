

import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/menu/data/datasources/menu_local_data_source.dart';
import 'package:ahgzly_pos/features/menu/data/models/category_model.dart';
import 'package:ahgzly_pos/features/menu/data/models/item_model.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';
import 'package:ahgzly_pos/features/menu/domain/repositories/menu_repository.dart';
import 'package:dartz/dartz.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuLocalDataSource localDataSource;

  MenuRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await localDataSource.getCategories();
      return Right(categories.cast<Category>());
    } catch (e) {
      return Left(DatabaseFailure('فشل في جلب الفئات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> addCategory(Category category) async {
    try {
      final categoryModel = CategoryModel(
        name: category.name,
        imagePath: category.imagePath,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
      );
      final id = await localDataSource.addCategory(categoryModel);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('فشل في إضافة الفئة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> updateCategory(Category category) async {
    try {
      final categoryModel = CategoryModel(
        id: category.id,
        name: category.name,
        imagePath: category.imagePath,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
      );
      final result = await localDataSource.updateCategory(categoryModel);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure('فشل في تحديث الفئة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteCategory(int id) async {
    try {
      final result = await localDataSource.deleteCategory(id);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure('فشل في حذف الفئة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getItems(int categoryId) async {
    try {
      final items = await localDataSource.getItems(categoryId);
      return Right(items);
    } catch (e) {
      return Left(DatabaseFailure('فشل في جلب الأصناف: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> addItem(Item item) async {
    try {
      final itemModel = ItemModel(
        categoryId: item.categoryId,
        name: item.name,
        price: item.price,
        imagePath: item.imagePath,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
      final id = await localDataSource.addItem(itemModel);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('فشل في إضافة الصنف: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> updateItem(Item item) async {
    try {
      final itemModel = ItemModel(
        id: item.id,
        categoryId: item.categoryId,
        name: item.name,
        price: item.price,
        imagePath: item.imagePath,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
      final result = await localDataSource.updateItem(itemModel);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure('فشل في تحديث الصنف: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteItem(int id) async {
    try {
      final result = await localDataSource.deleteItem(id);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure('فشل في حذف الصنف: ${e.toString()}'));
    }
  }
}