import 'package:ahgzly_pos/core/extensions/order_status.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:equatable/equatable.dart';


class OrderHistoryEntity extends Equatable {
  final int id;
  final OrderType orderType;
  final int subTotal;
  final int discount;
  final int total;
  final int? paymentMethodId;
  final String paymentMethodName;
  final DateTime createdAt;
  final OrderStatus status;
  final List<OrderItemHistoryEntity> items;

  const OrderHistoryEntity({
    required this.id,
    required this.orderType,
    required this.subTotal,
    required this.discount,
    required this.total,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.createdAt,
    required this.status,
    required this.items,
  });

  @override
  List<Object?> get props => [
    id, orderType, subTotal, discount, total, 
    paymentMethodId, paymentMethodName, createdAt, status, items
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