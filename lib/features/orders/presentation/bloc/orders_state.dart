import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';

abstract class OrdersState extends Equatable {
  @override
  List<Object> get props => [];
}
class OrdersInitial extends OrdersState {}
class OrdersLoading extends OrdersState {}
class OrdersLoaded extends OrdersState {
  final List<OrderHistory> orders;
  OrdersLoaded(this.orders);
  @override
  List<Object> get props => [orders];
}
class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
  @override
  List<Object> get props => [message];
}