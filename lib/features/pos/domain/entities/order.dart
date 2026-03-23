import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item.dart';

class Order extends Equatable {
  final int? id;
  final String orderType; // 'صالة', 'تيك أواي', 'دليفري'
  final double subTotal;
  final double taxAmount;
  final double serviceFee;
  final double deliveryFee;
  final double total;
  final String paymentMethod; // 'كاش', 'فيزا', 'InstaPay'
  final String status; // 'مكتمل', 'معلق', 'ملغي'
  final String createdAt;
  final List<OrderItem> items; // عناصر الطلب المرتبطة

  const Order({
    this.id,
    required this.orderType,
    required this.subTotal,
    required this.taxAmount,
    required this.serviceFee,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  @override
  List<Object?> get props => [
        id,
        orderType,
        subTotal,
        taxAmount,
        serviceFee,
        deliveryFee,
        total,
        paymentMethod,
        status,
        createdAt,
        items,
      ];
}