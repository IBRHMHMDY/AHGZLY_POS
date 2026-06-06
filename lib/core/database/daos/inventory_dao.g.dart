// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $InventoryItemsTable get inventoryItems => attachedDatabase.inventoryItems;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ItemsTable get items => attachedDatabase.items;
  $ItemVariantsTable get itemVariants => attachedDatabase.itemVariants;
  $AddonsTable get addons => attachedDatabase.addons;
  $RecipesTable get recipes => attachedDatabase.recipes;
  InventoryDaoManager get managers => InventoryDaoManager(this);
}

class InventoryDaoManager {
  final _$InventoryDaoMixin _db;
  InventoryDaoManager(this._db);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(
        _db.attachedDatabase,
        _db.inventoryItems,
      );
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ItemVariantsTableTableManager get itemVariants =>
      $$ItemVariantsTableTableManager(_db.attachedDatabase, _db.itemVariants);
  $$AddonsTableTableManager get addons =>
      $$AddonsTableTableManager(_db.attachedDatabase, _db.addons);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db.attachedDatabase, _db.recipes);
}
