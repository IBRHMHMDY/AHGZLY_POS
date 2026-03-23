import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';

// كلاس مساعد لتمثيل العنصر داخل سلة المشتريات (UI State)
class CartItem extends Equatable {
  final Item item;
  final int quantity;
  final String? notes;

  const CartItem({required this.item, required this.quantity, this.notes});

  CartItem copyWith({Item? item, int? quantity, String? notes}) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [item, quantity, notes];
}

abstract class PosState extends Equatable {
  const PosState();
  @override
  List<Object?> get props => [];
}

class PosInitial extends PosState {}

class PosUpdated extends PosState {
  final List<CartItem> cartItems;
  final String orderType;
  final double subTotal;
  final double taxAmount;
  final double serviceFee;
  final double deliveryFee;
  final double total;

  const PosUpdated({
    required this.cartItems,
    required this.orderType,
    required this.subTotal,
    required this.taxAmount,
    required this.serviceFee,
    required this.deliveryFee,
    required this.total,
  });

  PosUpdated copyWith({
    List<CartItem>? cartItems,
    String? orderType,
    double? subTotal,
    double? taxAmount,
    double? serviceFee,
    double? deliveryFee,
    double? total,
  }) {
    return PosUpdated(
      cartItems: cartItems ?? this.cartItems,
      orderType: orderType ?? this.orderType,
      subTotal: subTotal ?? this.subTotal,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceFee: serviceFee ?? this.serviceFee,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [cartItems, orderType, subTotal, taxAmount, serviceFee, deliveryFee, total];
}

class PosLoading extends PosState {}

class PosCheckoutSuccess extends PosState {
  final int orderId;
  const PosCheckoutSuccess(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class PosError extends PosState {
  final String message;
  const PosError(this.message);
  @override
  List<Object?> get props => [message];
}