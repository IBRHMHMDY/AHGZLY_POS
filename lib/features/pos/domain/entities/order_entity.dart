import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';

class Order extends Equatable {
  final int? shiftId; 
  final String orderType;
  final int subTotal;    // Refactored: int (Cents)
  final int discount;    // Refactored: int (Cents)
  final int taxAmount;   // Refactored: int (Cents)
  final int serviceFee;  // Refactored: int (Cents)
  final int deliveryFee; // Refactored: int (Cents)
  final int total;       // Refactored: int (Cents)
  final String paymentMethod;
  final String status;
  final String createdAt;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItemEntity> items;

  const Order({
    this.shiftId,
    required this.orderType, 
    required this.subTotal, 
    required this.discount, 
    required this.taxAmount,
    required this.serviceFee, 
    required this.deliveryFee, 
    required this.total, 
    required this.paymentMethod,
    required this.status, 
    required this.createdAt, 
    this.customerName = '', 
    this.customerPhone = '', 
    this.customerAddress = '', 
    required this.items,
  });

  @override
  List<Object?> get props => [
    shiftId, orderType, subTotal, discount, taxAmount, serviceFee, 
    deliveryFee, total, paymentMethod, status, createdAt, 
    customerName, customerPhone, customerAddress, items
  ];
}