

import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/features/menu/data/models/category_model.dart';
import 'package:ahgzly_pos/features/menu/data/models/item_model.dart';

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
  final DatabaseHelper databaseHelper;

  MenuLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  @override
  Future<int> addCategory(CategoryModel category) async {
    final db = await databaseHelper.database;
    return await db.insert('categories', category.toMap());
  }

  @override
  Future<int> updateCategory(CategoryModel category) async {
    final db = await databaseHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<int> deleteCategory(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ItemModel>> getItems(int categoryId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => ItemModel.fromMap(maps[i]));
  }

  @override
  Future<int> addItem(ItemModel item) async {
    final db = await databaseHelper.database;
    return await db.insert('items', item.toMap());
  }

  @override
  Future<int> updateItem(ItemModel item) async {
    final db = await databaseHelper.database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<int> deleteItem(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}