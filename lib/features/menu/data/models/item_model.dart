import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/features/menu/data/models/item_variant_model.dart';
import 'package:ahgzly_pos/features/menu/data/models/addon_model.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    super.id,
    required super.categoryId,
    required super.name,
    required super.price,
    required super.costPrice,
    super.imagePath,
    required super.createdAt,
    required super.updatedAt,
    super.variants = const [],
    super.availableAddons = const [],
  });

  factory ItemModel.fromDrift(
    ItemData data, {
    List<ItemVariantModel> variants = const [],
    List<AddonModel> addons = const [],
  }) {
    return ItemModel(
      id: data.id,
      categoryId: data.categoryId,
      name: data.name,
      price: data.price,
      costPrice: data.costPrice,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt, 
      variants: variants,
      availableAddons: addons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'cost_price': costPrice,
      // 'image_path': imagePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}