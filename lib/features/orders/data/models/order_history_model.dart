import 'package:ahgzly_pos/features/orders/domain/entities/order_history_entity.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; // للوصول إلى OrderData

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

  // [Refactor]: دالة Factory تقرأ البيانات مباشرة من Drift بفضل الـ TypeConverters
  factory OrderHistoryModel.fromDrift(OrderData order, List<OrderItemHistoryModel> items) {
    return OrderHistoryModel(
      id: order.id,
      orderType: order.orderType,       // ممرر كـ Enum تلقائياً
      subTotal: order.subTotal,
      discount: order.discount,
      total: order.total,
      paymentMethod: order.paymentMethod, // ممرر كـ Enum تلقائياً
      createdAt: order.createdAt,         // ممرر كـ DateTime تلقائياً
      status: order.status,               // ممرر كـ Enum تلقائياً
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
  
  // [Refactor]: قراءة مباشرة
  factory OrderItemHistoryModel.fromDrift(String name, int quantity, int unitPrice) {
    return OrderItemHistoryModel(
      itemName: name,
      quantity: quantity,
      unitPrice: unitPrice, 
    );
  }
}