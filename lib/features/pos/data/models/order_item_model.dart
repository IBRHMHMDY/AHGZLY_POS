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
    super.selectedVariant, // 🚀 [تمت الإضافة]
    super.selectedAddons,  // 🚀 [تمت الإضافة]
  });

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      itemId: entity.itemId,
      itemName: entity.itemName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      unitCostPrice: entity.unitCostPrice,
      notes: entity.notes,
      selectedVariant: entity.selectedVariant, // 🚀 [تمرير المقاس]
      selectedAddons: entity.selectedAddons,   // 🚀 [تمرير الإضافات]
    );
  }

  // سيتم استخدام هذه الدالة لإدخال البيانات الأساسية في جدول OrderItems
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      'item_id': itemId,
      'variant_id': selectedVariant?.id, // 🚀 [تمت الإضافة: حفظ ID المقاس]
      'quantity': quantity,
      'unit_price': unitPrice,
      'unit_cost_price': unitCostPrice,
      'notes': notes,
    };
  }
}