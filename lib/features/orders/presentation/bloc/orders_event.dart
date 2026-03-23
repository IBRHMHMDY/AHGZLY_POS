import 'package:equatable/equatable.dart';
abstract class OrdersEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadOrdersEvent extends OrdersEvent {}