import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/menu/data/datasources/menu_local_data_source.dart';
import 'package:ahgzly_pos/features/menu/data/models/category_model.dart';
import 'package:ahgzly_pos/features/menu/data/models/item_model.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/repositories/menu_repository.dart';
import 'package:dartz/dartz.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuLocalDataSource localDataSource;

  MenuRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await localDataSource.getCategories();
      return Right(categories.cast<CategoryEntity>());
    } catch (_) {
      // Refactored: إخفاء تفاصيل الخطأ التقنية عن المستخدم
      return const Left(DatabaseFailure('فشل في جلب الأقسام. تأكد من اتصال قاعدة البيانات.'));
    }
  }

  @override
  Future<Either<Failure, int>> addCategory(CategoryEntity category) async {
    try {
      final categoryModel = CategoryModel(
        name: category.name, imagePath: category.imagePath, createdAt: category.createdAt, updatedAt: category.updatedAt,
      );
      final id = await localDataSource.addCategory(categoryModel);
      return Right(id);
    } catch (_) {
      return const Left(DatabaseFailure('فشل في إضافة القسم. يرجى المحاولة لاحقاً.'));
    }
  }

  @override
  Future<Either<Failure, int>> updateCategory(CategoryEntity category) async {
    try {
      final categoryModel = CategoryModel(
        id: category.id, name: category.name, imagePath: category.imagePath, createdAt: category.createdAt, updatedAt: category.updatedAt,
      );
      final result = await localDataSource.updateCategory(categoryModel);
      return Right(result);
    } catch (_) {
      return const Left(DatabaseFailure('فشل في تحديث القسم.'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteCategory(int id) async {
    try {
      final result = await localDataSource.deleteCategory(id);
      return Right(result);
    } catch (_) {
      return const Left(DatabaseFailure('لا يمكن حذف القسم، قد يكون مرتبطاً بمنتجات أخرى.'));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems(int categoryId) async {
    try {
      final items = await localDataSource.getItems(categoryId);
      return Right(items);
    } catch (_) {
      return const Left(DatabaseFailure('فشل في جلب الأصناف.'));
    }
  }

  @override
  Future<Either<Failure, int>> addItem(ItemEntity item) async {
    try {
      final itemModel = ItemModel(
        categoryId: item.categoryId, name: item.name, price: item.price, imagePath: item.imagePath, createdAt: item.createdAt, updatedAt: item.updatedAt,
      );
      final id = await localDataSource.addItem(itemModel);
      return Right(id);
    } catch (_) {
      return const Left(DatabaseFailure('فشل في إضافة الصنف.'));
    }
  }

  @override
  Future<Either<Failure, int>> updateItem(ItemEntity item) async {
    try {
      final itemModel = ItemModel(
        id: item.id, categoryId: item.categoryId, name: item.name, price: item.price, imagePath: item.imagePath, createdAt: item.createdAt, updatedAt: item.updatedAt,
      );
      final result = await localDataSource.updateItem(itemModel);
      return Right(result);
    } catch (_) {
      return const Left(DatabaseFailure('فشل في تحديث الصنف.'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteItem(int id) async {
    try {
      final result = await localDataSource.deleteItem(id);
      return Right(result);
    } catch (_) {
      return const Left(DatabaseFailure('لا يمكن حذف الصنف، قد يكون موجوداً في سجل الطلبات.'));
    }
  }
}