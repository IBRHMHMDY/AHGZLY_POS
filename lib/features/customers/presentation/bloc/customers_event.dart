import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';

abstract class CustomersEvent extends Equatable {
  const CustomersEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomersEvent {
  final String? searchQuery;
  const LoadCustomersEvent({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class AddCustomerEvent extends CustomersEvent {
  final CustomersCompanion customer;
  const AddCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomerEvent extends CustomersEvent {
  final CustomersCompanion customer;
  const UpdateCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerEvent extends CustomersEvent {
  final int id;
  const DeleteCustomerEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCustomerDetailEvent extends CustomersEvent {
  final int customerId;
  const LoadCustomerDetailEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
