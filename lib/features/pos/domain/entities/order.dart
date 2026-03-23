import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item.dart';

class Order extends Equatable {
  final String orderType;
  final double subTotal;
  final double discount; // جديد
  final double taxAmount;
  final double serviceFee;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String status;
  final String createdAt;
  final List<OrderItem> items;

  const Order({
    required this.orderType, required this.subTotal, required this.discount, required this.taxAmount,
    required this.serviceFee, required this.deliveryFee, required this.total, required this.paymentMethod,
    required this.status, required this.createdAt, required this.items,
  });

  @override
  List<Object?> get props => [orderType, subTotal, discount, taxAmount, serviceFee, deliveryFee, total, paymentMethod, status, createdAt, items];
}