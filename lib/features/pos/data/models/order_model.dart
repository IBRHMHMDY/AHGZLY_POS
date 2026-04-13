import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    super.shiftId,
    required super.orderType,
    required super.subTotal,
    required super.discount,
    required super.taxAmount,
    required super.serviceFee,
    required super.deliveryFee,
    required super.total,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
    super.customerName,
    super.customerPhone,
    super.customerAddress,
    required super.items,
  });

  factory OrderModel.fromEntity(Order entity) {
    return OrderModel(
      shiftId: entity.shiftId,
      orderType: entity.orderType,
      subTotal: entity.subTotal,
      discount: entity.discount,
      taxAmount: entity.taxAmount,
      serviceFee: entity.serviceFee,
      deliveryFee: entity.deliveryFee,
      total: entity.total,
      paymentMethod: entity.paymentMethod,
      status: entity.status,
      createdAt: entity.createdAt,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      customerAddress: entity.customerAddress,
      items: entity.items
          .map((item) => OrderItemModel.fromEntity(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shift_id': shiftId, // تمت الإضافة
      'order_type': orderType,
      'sub_total': subTotal,
      'discount': discount,
      'tax_amount': taxAmount,
      'service_fee': serviceFee,
      'delivery_fee': deliveryFee,
      'total': total,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
    };
  }
}