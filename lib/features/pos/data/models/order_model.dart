import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    super.id,
    required super.orderType,
    required super.subTotal,
    required super.taxAmount,
    required super.serviceFee,
    required super.deliveryFee,
    required super.total,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
    required super.items,
  });

  factory OrderModel.fromEntity(Order entity) {
    return OrderModel(
      id: entity.id,
      orderType: entity.orderType,
      subTotal: entity.subTotal,
      taxAmount: entity.taxAmount,
      serviceFee: entity.serviceFee,
      deliveryFee: entity.deliveryFee,
      total: entity.total,
      paymentMethod: entity.paymentMethod,
      status: entity.status,
      createdAt: entity.createdAt,
      items: entity.items.map((item) => OrderItemModel.fromEntity(item)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_type': orderType,
      'sub_total': subTotal,
      'tax_amount': taxAmount,
      'service_fee': serviceFee,
      'delivery_fee': deliveryFee,
      'total': total,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt,
    };
  }
}