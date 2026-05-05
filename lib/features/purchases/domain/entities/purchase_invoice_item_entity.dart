import 'package:equatable/equatable.dart';

class PurchaseInvoiceItemEntity extends Equatable {
  final int id;
  final int invoiceId;
  final int inventoryItemId;
  final double quantity;
  final int unitCost;
  final int totalCost;

  const PurchaseInvoiceItemEntity({
    required this.id,
    required this.invoiceId,
    required this.inventoryItemId,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        inventoryItemId,
        quantity,
        unitCost,
        totalCost,
      ];
}
