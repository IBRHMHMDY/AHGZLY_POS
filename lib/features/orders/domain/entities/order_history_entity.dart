// مسار الملف: lib/features/orders/domain/entities/order_history_entity.dart

import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:equatable/equatable.dart';


class OrderHistoryEntity extends Equatable {
  final int id;
  final OrderType orderType; // [Refactored] String -> Enum
  final int subTotal;
  final int discount;
  final int total;
  final PaymentMethod paymentMethod; // [Refactored] String -> Enum
  final DateTime createdAt; // [Refactored] String -> DateTime
  final OrderStatus status; // [Refactored] String -> Enum
  final List<OrderItemHistoryEntity> items;

  const OrderHistoryEntity({
    required this.id,
    required this.orderType,
    required this.subTotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    required this.status,
    required this.items,
  });

  @override
  List<Object?> get props => [
    id, orderType, subTotal, discount, total, 
    paymentMethod, createdAt, status, items
  ];
}

class OrderItemHistoryEntity extends Equatable {
  final String itemName;
  final int quantity;
  final int unitPrice;

  const OrderItemHistoryEntity({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [itemName, quantity, unitPrice];
}