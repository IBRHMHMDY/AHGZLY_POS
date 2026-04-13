// مسار الملف: lib/features/orders/data/models/order_history_model.dart

import 'package:ahgzly_pos/features/orders/domain/entities/order_history_entity.dart';
import 'package:ahgzly_pos/core/common/enums/order_type.dart';
import 'package:ahgzly_pos/core/common/enums/payment_method.dart';
import 'package:ahgzly_pos/core/common/enums/order_status.dart';

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
      // [Clean Code]: قراءة النص من الداتابيز وتحويله لـ Enum باستخدام الدالة المساعدة
      orderType: OrderType.fromString(map['order_type'] as String),
      subTotal: (map['sub_total'] as num).toInt(),
      discount: (map['discount'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num).toInt(),
      paymentMethod: PaymentMethod.fromString(map['payment_method'] as String),
      createdAt: DateTime.parse(map['created_at'] as String), // تحويل لنوع DateTime
      status: OrderStatus.fromString(map['status'] as String),
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
      unitPrice: (map['unit_price'] as num).toInt(), 
    );
  }
}