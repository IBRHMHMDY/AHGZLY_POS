import 'package:ahgzly_pos/features/orders/domain/entities/order_history_entity.dart';

class OrderHistoryModel extends OrderHistoryEntity {
  const OrderHistoryModel({
    required super.id,
    required super.orderType,
    required super.subTotal,
    required super.discount,
    required super.total,
    required super.paymentMethod,
    required super.createdAt,
    required super.status,
    required super.items,
  });

  factory OrderHistoryModel.fromMap(
    Map<String, dynamic> map,
    List<OrderItemHistoryModel> items,
  ) {
    return OrderHistoryModel(
      id: map['id'] as int,
      orderType: map['order_type'] as String,
      // Refactored: تحويل إلى int بدلاً من double
      subTotal: (map['sub_total'] as num).toInt(),
      // Refactored: تحويل إلى int وضبط القيمة الافتراضية لـ 0 بدلاً من 0.0
      discount: (map['discount'] as num?)?.toInt() ?? 0,
      // Refactored: تحويل إلى int بدلاً من double
      total: (map['total'] as num).toInt(),
      paymentMethod: map['payment_method'] as String,
      createdAt: map['created_at'] as String,
      status: map['status'] as String,
      items: items,
    );
  }
}

class OrderItemHistoryModel extends OrderItemHistoryEntity {
  const OrderItemHistoryModel({
    required super.itemName,
    required super.quantity,
    required super.unitPrice,
  });
  
  factory OrderItemHistoryModel.fromMap(Map<String, dynamic> map) {
    return OrderItemHistoryModel(
      itemName: map['item_name'] as String,
      quantity: map['quantity'] as int,
      // Refactored: تحويل إلى int بدلاً من double
      unitPrice: (map['unit_price'] as num).toInt(), 
    );
  }
}