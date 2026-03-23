import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object> get props => [];
}

class AddItemToCartEvent extends PosEvent {
  final Item item;
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
  final String orderType; // 'صالة', 'تيك أواي', 'دليفري'
  const ChangeOrderTypeEvent(this.orderType);
  @override
  List<Object> get props => [orderType];
}

class SubmitOrderEvent extends PosEvent {
  final String paymentMethod; // 'كاش', 'فيزا', 'InstaPay'
  const SubmitOrderEvent(this.paymentMethod);
  @override
  List<Object> get props => [paymentMethod];
}

class ClearCartEvent extends PosEvent {}

class ReloadSettingsEvent extends PosEvent {}