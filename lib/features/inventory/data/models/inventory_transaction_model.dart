import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/inventory/domain/entities/inventory_transaction_entity.dart';

class InventoryTransactionModel extends InventoryTransactionEntity {
  const InventoryTransactionModel({
    required super.id,
    required super.inventoryItemId,
    required super.transactionType,
    required super.quantity,
    super.referenceId,
    super.notes,
    required super.createdAt,
  });

  factory InventoryTransactionModel.fromDrift(InventoryTransactionData data) {
    return InventoryTransactionModel(
      id: data.id,
      inventoryItemId: data.inventoryItemId,
      transactionType: data.transactionType,
      quantity: data.quantity,
      referenceId: data.referenceId,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }
}
