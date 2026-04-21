import 'package:ahgzly_pos/features/orders/domain/entities/order_history_entity.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; 

class OrderHistoryModel extends OrderHistoryEntity {
  const OrderHistoryModel({
    required super.id,
    required super.orderType,
    required super.subTotal,
    required super.discount,
    required super.total,
    super.paymentMethodId,
    super.paymentMethodName = 'غير محدد',
    required super.createdAt,
    required super.status,
    required super.items,
  });

  // 🚀 استقبال اسم طريقة الدفع كمتغير اختياري
  factory OrderHistoryModel.fromDrift(
    OrderData order, 
    List<OrderItemHistoryModel> items, {
    String paymentMethodName = 'غير محدد', 
  }) {
    return OrderHistoryModel(
      id: order.id,
      orderType: order.orderType,       
      subTotal: order.subTotal,
      discount: order.discount,
      total: order.total,
      paymentMethodId: order.paymentMethodId, 
      paymentMethodName: paymentMethodName, // 🚀 تمريره للـ Entity
      createdAt: order.createdAt,         
      status: order.status,               
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
  
  factory OrderItemHistoryModel.fromDrift(String name, int quantity, int unitPrice) {
    return OrderItemHistoryModel(
      itemName: name,
      quantity: quantity,
      unitPrice: unitPrice, 
    );
  }
}