import 'package:equatable/equatable.dart';

class OrderHistoryItem extends Equatable {
  final String itemName;
  final int quantity;
  final double unitPrice;

  const OrderHistoryItem({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [itemName, quantity, unitPrice];
}

class OrderHistory extends Equatable {
  final int id;
  final String orderType;
  final double total;
  final String paymentMethod;
  final String createdAt;
  final List<OrderHistoryItem> items;

  const OrderHistory({
    required this.id,
    required this.orderType,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  @override
  List<Object?> get props => [id, orderType, total, paymentMethod, createdAt, items];
}