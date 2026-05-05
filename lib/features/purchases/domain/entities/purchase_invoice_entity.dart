import 'package:equatable/equatable.dart';

class PurchaseInvoiceEntity extends Equatable {
  final int id;
  final int? supplierId;
  final int totalAmount;
  final int paidAmount;
  final DateTime invoiceDate;
  final String? notes;
  final DateTime createdAt;

  const PurchaseInvoiceEntity({
    required this.id,
    this.supplierId,
    required this.totalAmount,
    required this.paidAmount,
    required this.invoiceDate,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        supplierId,
        totalAmount,
        paidAmount,
        invoiceDate,
        notes,
        createdAt,
      ];
}
