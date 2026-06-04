import 'package:equatable/equatable.dart';
import '../../../../shared/data/models/customer_model.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object?> get props => [];
}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}

class CustomersLoaded extends CustomersState {
  final List<CustomerModel> customers;
  final String? searchQuery;

  const CustomersLoaded({required this.customers, this.searchQuery});

  @override
  List<Object?> get props => [customers, searchQuery];
}

class CustomerDetailLoaded extends CustomersState {
  final CustomerDetailModel detail;
  const CustomerDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

class CustomersError extends CustomersState {
  final String message;
  const CustomersError(this.message);

  @override
  List<Object?> get props => [message];
}
