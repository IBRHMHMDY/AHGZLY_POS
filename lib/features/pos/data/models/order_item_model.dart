import 'package:ahgzly_pos/features/pos/domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    super.id,
    super.orderId,
    required super.itemId,
    required super.quantity,
    required super.unitPrice,
    super.notes,
  });

  factory OrderItemModel.fromEntity(OrderItem entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      itemId: entity.itemId,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
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
      'notes': notes,
    };
  }
}