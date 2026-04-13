import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:ahgzly_pos/core/extensions/payment_method.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object> get props => [];
}

class SaveOrderEvent extends PosEvent {
  final OrderEntity order;
  const SaveOrderEvent(this.order);
  @override
  List<Object> get props => [order];
}

class AddItemToCartEvent extends PosEvent {
  final ItemEntity item;
  const AddItemToCartEvent(this.item);
  @override
  List<Object> get props => [item];
}

class UpdateCartItemQuantityEvent extends PosEvent {
  final int index;
  final int quantity;
  const UpdateCartItemQuantityEvent(this.index, this.quantity);
  @override
  List<Object> get props => [index, quantity];
}

class RemoveItemFromCartEvent extends PosEvent {
  final int index;
  const RemoveItemFromCartEvent(this.index);
  @override
  List<Object> get props => [index];
}

class ChangeOrderTypeEvent extends PosEvent {
  final OrderType orderType;
  const ChangeOrderTypeEvent(this.orderType);
  @override
  List<Object> get props => [orderType];
}

class SubmitOrderEvent extends PosEvent {
  final PaymentMethod paymentMethod;
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  const SubmitOrderEvent(
    this.paymentMethod, {
    this.customerName = '',
    this.customerPhone = '',
    this.customerAddress = '',
  });

  @override
  List<Object> get props => [
    paymentMethod,
    customerName,
    customerPhone,
    customerAddress,
  ];
}

class ClearCartEvent extends PosEvent {}

class ReloadSettingsEvent extends PosEvent {}

class ApplyDiscountEvent extends PosEvent {
  final int discountAmount;
  const ApplyDiscountEvent(this.discountAmount);
  @override
  List<Object> get props => [discountAmount];
}
