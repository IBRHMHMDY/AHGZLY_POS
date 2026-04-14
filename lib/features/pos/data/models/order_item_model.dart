// مسار الملف: lib/features/pos/data/models/order_item_model.dart
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    super.id,
    super.orderId,
    required super.itemId,
    required super.quantity,
    required super.unitPrice,
    required super.unitCost, // [Refactored]
    super.notes,
  });

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      itemId: entity.itemId,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      unitCost: entity.unitCost, // [Refactored]
      notes: entity.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      'item_id': itemId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'unit_cost': unitCost, // [Refactored]
      'notes': notes,
    };
  }
}