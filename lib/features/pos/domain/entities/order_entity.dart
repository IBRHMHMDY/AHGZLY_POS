// مسار الملف: lib/features/pos/domain/entities/order_entity.dart

import 'package:ahgzly_pos/core/common/enums/enums_data.dart';
import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';

class OrderEntity extends Equatable {
  final int? shiftId; 
  final int? tableId; // [Added] لدعم نظام الصالات والطاولات لاحقاً
  final OrderType orderType; // [Refactored] String -> Enum
  final int subTotal;    
  final int discount;    
  final int taxAmount;   
  final int serviceFee;  
  final int deliveryFee; 
  final int total;       
  final PaymentMethod paymentMethod; // [Refactored] String -> Enum
  final OrderStatus status; // [Refactored] String -> Enum
  final DateTime createdAt; // [Refactored] String -> DateTime
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItemEntity> items;

  const OrderEntity({
    this.shiftId,
    this.tableId,
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
    shiftId, tableId, orderType, subTotal, discount, taxAmount, serviceFee, 
    deliveryFee, total, paymentMethod, status, createdAt, 
    customerName, customerPhone, customerAddress, items
  ];
}