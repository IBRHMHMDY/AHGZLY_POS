import 'package:equatable/equatable.dart';
import '../../domain/entities/purchase_invoice_entity.dart';

abstract class PurchasesState extends Equatable {
  const PurchasesState();

  @override
  List<Object?> get props => [];
}

class PurchasesInitial extends PurchasesState {}

class PurchasesLoading extends PurchasesState {}

class PurchasesLoaded extends PurchasesState {
  final List<PurchaseInvoiceEntity> invoices;

  const PurchasesLoaded({required this.invoices});

  @override
  List<Object?> get props => [invoices];
}

class PurchaseInvoiceSavedSuccess extends PurchasesState {}

class PurchasesError extends PurchasesState {
  final String message;
  const PurchasesError(this.message);

  @override
  List<Object?> get props => [message];
}
