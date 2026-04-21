import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    super.id,
    super.orderId,
    required super.itemId,
    required super.itemName,
    required super.quantity,
    required super.unitPrice,
    required super.unitCostPrice,
    super.notes,
  });

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      itemId: entity.itemId,
      itemName: entity.itemName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      unitCostPrice: entity.unitCostPrice, // 🚀 [تم إصلاح الخطأ الإملائي]
      notes: entity.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'unit_cost_price': unitCostPrice,
      'notes': notes,
    };
  }
}