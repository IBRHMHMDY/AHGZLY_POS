import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/features/menu/data/models/category_model.dart';
import 'package:ahgzly_pos/features/menu/data/models/item_model.dart';
import 'package:drift/drift.dart';

abstract class MenuLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<int> addCategory(CategoryModel category);
  Future<int> updateCategory(CategoryModel category);
  Future<int> deleteCategory(int id);

  Future<List<ItemModel>> getItems(int categoryId);
  Future<int> addItem(ItemModel item);
  Future<int> updateItem(ItemModel item);
  Future<int> deleteItem(int id);
}

class MenuLocalDataSourceImpl implements MenuLocalDataSource {
  final AppDatabase appDatabase; 

  MenuLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final maps = await appDatabase.select(appDatabase.categories).get();
    // [Refactored]: الاعتماد على Factory المباشر
    return maps.map((c) => CategoryModel.fromDrift(c)).toList();
  }

  @override
  Future<int> addCategory(CategoryModel category) async {
    return await appDatabase.into(appDatabase.categories).insert(
          CategoriesCompanion.insert(
            name: category.name,
            // [Refactored]: التواريخ ستُمرر كـ DateTime تلقائياً
            createdAt: category.createdAt,
            updatedAt: category.updatedAt,
          ),
        );
  }

  @override
  Future<int> updateCategory(CategoryModel category) async {
    await (appDatabase.update(appDatabase.categories)
          ..where((t) => t.id.equals(category.id!)))
        .write(
      CategoriesCompanion(
        name: Value(category.name),
        updatedAt: Value(category.updatedAt),
      ),
    );
    return category.id!;
  }

  @override
  Future<int> deleteCategory(int id) async {
    return await (appDatabase.delete(appDatabase.categories)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<List<ItemModel>> getItems(int categoryId) async {
    final maps = await (appDatabase.select(appDatabase.items)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .get();
    // [Refactored]: الاعتماد على Factory المباشر
    return maps.map((i) => ItemModel.fromDrift(i)).toList();
  }

  @override
  Future<int> addItem(ItemModel item) async {
    return await appDatabase.into(appDatabase.items).insert(
          ItemsCompanion.insert(
            categoryId: item.categoryId,
            name: item.name,
            price: item.price,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          ),
        );
  }

  @override
  Future<int> updateItem(ItemModel item) async {
    await (appDatabase.update(appDatabase.items)
          ..where((t) => t.id.equals(item.id!)))
        .write(
      ItemsCompanion(
        categoryId: Value(item.categoryId),
        name: Value(item.name),
        price: Value(item.price),
        updatedAt: Value(item.updatedAt),
      ),
    );
    return item.id!;
  }

  @override
  Future<int> deleteItem(int id) async {
    return await (appDatabase.delete(appDatabase.items)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}