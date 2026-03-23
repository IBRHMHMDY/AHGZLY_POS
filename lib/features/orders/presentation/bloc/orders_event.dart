import 'package:equatable/equatable.dart';
abstract class OrdersEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadOrdersEvent extends OrdersEvent {}

class RefundOrderEvent extends OrdersEvent {
  final int orderId;
  RefundOrderEvent(this.orderId);
  @override
  List<Object> get props => [orderId];
}