import 'package:equatable/equatable.dart';

class InventoryTransactionEntity extends Equatable {
  final int id;
  final int inventoryItemId;
  final String transactionType; // 'in', 'out', 'waste', 'sale'
  final double quantity;
  final int? referenceId; // orderId or purchaseInvoiceId
  final String? notes;
  final DateTime createdAt;

  const InventoryTransactionEntity({
    required this.id,
    required this.inventoryItemId,
    required this.transactionType,
    required this.quantity,
    this.referenceId,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        inventoryItemId,
        transactionType,
        quantity,
        referenceId,
        notes,
        createdAt,
      ];
}
