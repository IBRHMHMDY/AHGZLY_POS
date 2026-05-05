import 'package:equatable/equatable.dart';
import '../../data/models/purchase_invoice_item_model.dart';

abstract class PurchasesEvent extends Equatable {
  const PurchasesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchasesEvent extends PurchasesEvent {}

class SavePurchaseInvoiceEvent extends PurchasesEvent {
  final int? supplierId;
  final int totalAmount;
  final int paidAmount;
  final String? notes;
  final List<PurchaseInvoiceItemModel> items;

  const SavePurchaseInvoiceEvent({
    required this.supplierId,
    required this.totalAmount,
    required this.paidAmount,
    required this.notes,
    required this.items,
  });

  @override
  List<Object?> get props => [supplierId, totalAmount, paidAmount, notes, items];
}
