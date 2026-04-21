import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_variant_entity.dart';

class ItemVariantModel extends ItemVariantEntity {
  const ItemVariantModel({
    super.id,
    required super.itemId,
    required super.name,
    required super.price,
    required super.costPrice,
  });

  factory ItemVariantModel.fromDrift(ItemVariantData data) {
    return ItemVariantModel(
      id: data.id,
      itemId: data.itemId,
      name: data.name,
      price: data.price,
      costPrice: data.costPrice,
    );
  }
}