import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';

class OrderHistoryItemModel extends OrderHistoryItem {
  const OrderHistoryItemModel({required super.itemName, required super.quantity, required super.unitPrice});
  factory OrderHistoryItemModel.fromMap(Map<String, dynamic> map) {
    return OrderHistoryItemModel(
      itemName: map['item_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
    );
  }
}

class OrderHistoryModel extends OrderHistory {
  const OrderHistoryModel({
    required super.id, required super.orderType, required super.total, required super.paymentMethod,
    required super.createdAt, required super.status, required super.items,
  });

  factory OrderHistoryModel.fromMap(Map<String, dynamic> map, List<OrderHistoryItemModel> items) {
    return OrderHistoryModel(
      id: map['id'] as int,
      orderType: map['order_type'] as String,
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      createdAt: map['created_at'] as String,
      status: map['status'] as String, // إضافة الحالة
      items: items,
    );
  }
}