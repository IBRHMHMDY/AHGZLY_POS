import 'package:equatable/equatable.dart';
abstract class OrdersEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadOrdersEvent extends OrdersEvent {
  final bool isAdmin;
  final int? shiftId;
  LoadOrdersEvent({required this.isAdmin, required this.shiftId});
}

class RefundOrderEvent extends OrdersEvent {
  final int orderId;
  final bool isAdmin;
  final int? shiftId;
  RefundOrderEvent({
    required this.orderId, 
    required this.isAdmin, 
    required this.shiftId
  });
  @override
  List<Object> get props => [orderId];
}