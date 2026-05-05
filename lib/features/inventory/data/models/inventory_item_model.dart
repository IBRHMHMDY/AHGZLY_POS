import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/inventory_item_entity.dart';

class InventoryItemModel extends InventoryItemEntity {
  const InventoryItemModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.stockQuantity,
    required super.costPerUnit,
  });

  factory InventoryItemModel.fromDrift(InventoryItemData data) {
    return InventoryItemModel(
      id: data.id,
      name: data.name,
      unit: data.unit,
      stockQuantity: data.stockQuantity,
      costPerUnit: data.costPerUnit,
    );
  }
}
