import 'package:equatable/equatable.dart';

class OrderHistoryEntity extends Equatable {
  final int id;
  final String orderType;
  final int subTotal; // Refactored: int (Cents)
  final int discount; // Refactored: int (Cents)
  final int total;    // Refactored: int (Cents)
  final String paymentMethod;
  final String createdAt;
  final String status;
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
    id, orderType, subTotal, discount, total, paymentMethod, createdAt, status, items,
  ];
}

class OrderItemHistoryEntity extends Equatable {
  final String itemName;
  final int quantity;
  final int unitPrice; // Refactored: تغيير من double إلى int (Cents)
  const OrderItemHistoryEntity({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });
  @override
  List<Object?> get props => [itemName, quantity, unitPrice];
}