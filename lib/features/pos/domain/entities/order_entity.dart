// مسار الملف: lib/features/pos/domain/entities/order_entity.dart

import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';

class OrderEntity extends Equatable {
  final int? shiftId; 
  final int? tableId; 
  final OrderType orderType; 
  final int subTotal;    
  final int discount;    
  final int taxAmount;   
  final int serviceFee;  
  final int deliveryFee; 
  final int total;       
  final PaymentMethod paymentMethod; 
  final OrderStatus status; 
  final DateTime createdAt; 
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

  // [Refactored]: إضافة قاعدة عمل للتحقق من صحة الطلب داخل الـ Entity نفسه
  // هذا يمنع إنشاء طلبات غير منطقية في أي مكان في التطبيق
  bool get isValid => total >= 0 && items.isNotEmpty;

  // [Refactored]: دالة لإنشاء نسخة جديدة من الطلب مع ربط الوردية (Immutability)
  OrderEntity copyWithShift(int newShiftId) {
    return OrderEntity(
      shiftId: newShiftId,
      tableId: tableId,
      orderType: orderType,
      subTotal: subTotal,
      discount: discount,
      taxAmount: taxAmount,
      serviceFee: serviceFee,
      deliveryFee: deliveryFee,
      total: total,
      paymentMethod: paymentMethod,
      status: status,
      createdAt: createdAt,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      items: items,
    );
  }

  @override
  List<Object?> get props => [
    shiftId, tableId, orderType, subTotal, discount, taxAmount, serviceFee, 
    deliveryFee, total, paymentMethod, status, createdAt, 
    customerName, customerPhone, customerAddress, items
  ];
}