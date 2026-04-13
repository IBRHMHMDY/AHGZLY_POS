import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';

class CartItem extends Equatable {
  final ItemEntity item;
  final int quantity;
  final String? notes;
  const CartItem({required this.item, required this.quantity, this.notes});
  CartItem copyWith({int? quantity, String? notes}) {
    return CartItem(item: item, quantity: quantity ?? this.quantity, notes: notes ?? this.notes);
  }
  @override
  List<Object?> get props => [item, quantity, notes];
}

abstract class PosState extends Equatable {
  @override
  List<Object> get props => [];
}

class PosInitial extends PosState {}
class PosLoading extends PosState {}

class PosUpdated extends PosState {
  final List<CartItem> cartItems;
  final OrderType orderType;
  final int subTotal;
  final int discountAmount; // جديد
  final int taxAmount;
  final int serviceFee;
  final int deliveryFee;
  final int total;
  final String restaurantName;
  final String taxNumber;
  final String printMode;

  PosUpdated({
    required this.cartItems, required this.orderType, required this.subTotal, required this.discountAmount,
    required this.taxAmount, required this.serviceFee, required this.deliveryFee, required this.total,
    required this.restaurantName, required this.taxNumber, required this.printMode,
  });

  @override
  List<Object> get props => [cartItems, orderType, subTotal, discountAmount, taxAmount, serviceFee, deliveryFee, total, restaurantName, taxNumber, printMode];
}

class PosCheckoutSuccess extends PosState {
  final int orderId;
  PosCheckoutSuccess(this.orderId);
  @override
  List<Object> get props => [orderId];
}

class PosError extends PosState {
  final String message;
  PosError(this.message);
  @override
  List<Object> get props => [message];
}