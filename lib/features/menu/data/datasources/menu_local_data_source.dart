import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/features/menu/data/models/category_model.dart';
import 'package:ahgzly_pos/features/menu/data/models/item_model.dart';
import 'package:ahgzly_pos/features/menu/data/models/item_variant_model.dart';
import 'package:ahgzly_pos/features/menu/data/models/addon_model.dart';
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
    return maps.map((c) => CategoryModel.fromDrift(c)).toList();
  }

  @override
  Future<int> addCategory(CategoryModel category) async {
    return await appDatabase.into(appDatabase.categories).insert(
          CategoriesCompanion.insert(
            name: category.name,
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
    return await (appDatabase.delete(appDatabase.categories)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<ItemModel>> getItems(int categoryId) async {
    final addonsData = await appDatabase.select(appDatabase.addons).get();
    final addons = addonsData.map((a) => AddonModel.fromDrift(a)).toList();

    final maps = await (appDatabase.select(appDatabase.items)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .get();

    List<ItemModel> items = [];
    
    for (var data in maps) {
      final variantsData = await (appDatabase.select(appDatabase.itemVariants)
          ..where((v) => v.itemId.equals(data.id))).get();
      final variants = variantsData.map((v) => ItemVariantModel.fromDrift(v)).toList();

      items.add(ItemModel.fromDrift(data, variants: variants, addons: addons));
    }
    
    return items;
  }

  @override
  Future<int> addItem(ItemModel item) async {
    return await appDatabase.transaction(() async {
      final itemId = await appDatabase.into(appDatabase.items).insert(
            ItemsCompanion.insert(
              categoryId: item.categoryId,
              name: item.name,
              price: item.price,
              costPrice: Value(item.costPrice),
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
            ),
          );

      for (var variant in item.variants) {
        await appDatabase.into(appDatabase.itemVariants).insert(
          ItemVariantsCompanion.insert(
            itemId: itemId, 
            name: variant.name,
            price: variant.price,
            costPrice: Value(variant.costPrice),
          ),
        );
      }
      return itemId;
    });
  }

  @override
  Future<int> updateItem(ItemModel item) async {
    return await appDatabase.transaction(() async {
      // 1. تحديث بيانات الصنف الأساسية
      await (appDatabase.update(appDatabase.items)..where((t) => t.id.equals(item.id!)))
          .write(
        ItemsCompanion(
          categoryId: Value(item.categoryId),
          name: Value(item.name),
          price: Value(item.price),
          costPrice: Value(item.costPrice),
          updatedAt: Value(item.updatedAt),
        ),
      );

      // 🚀 [Refactored UX/DB]: منع مسح المقاسات القديمة عشوائياً.
      // نطبق خوارزمية (Diffing) للتحديث لتجنب حدوث Foreign Key Constraint Error
      final existingVariants = await (appDatabase.select(appDatabase.itemVariants)..where((v) => v.itemId.equals(item.id!))).get();
      final incomingIds = item.variants.map((v) => v.id).where((id) => id != null).toList();

      // مسح المقاسات التي تمت إزالتها فقط (محاولة مسح آمنة)
      for (var existing in existingVariants) {
        if (!incomingIds.contains(existing.id)) {
          try {
            await (appDatabase.delete(appDatabase.itemVariants)..where((t) => t.id.equals(existing.id))).go();
          } catch (_) {
            // تجاهل المسح إذا كان المقاس مرتبطاً بفاتورة قديمة لحماية النظام
          }
        }
      }

      // إضافة الجديد أو تحديث الحالي
      for (var variant in item.variants) {
        if (variant.id != null) {
          await (appDatabase.update(appDatabase.itemVariants)..where((t) => t.id.equals(variant.id!)))
            .write(ItemVariantsCompanion(
              name: Value(variant.name),
              price: Value(variant.price),
              costPrice: Value(variant.costPrice),
            ));
        } else {
          await appDatabase.into(appDatabase.itemVariants).insert(
            ItemVariantsCompanion.insert(
              itemId: item.id!,
              name: variant.name,
              price: variant.price,
              costPrice: Value(variant.costPrice),
            ),
          );
        }
      }
      return item.id!;
    });
  }

  @override
  Future<int> deleteItem(int id) async {
    return await appDatabase.transaction(() async {
      await (appDatabase.delete(appDatabase.itemVariants)..where((v) => v.itemId.equals(id))).go();
      return await (appDatabase.delete(appDatabase.items)..where((t) => t.id.equals(id))).go();
    });
  }
}