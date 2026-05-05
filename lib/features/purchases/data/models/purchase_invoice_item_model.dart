import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/purchases/domain/entities/purchase_invoice_item_entity.dart';

class PurchaseInvoiceItemModel extends PurchaseInvoiceItemEntity {
  const PurchaseInvoiceItemModel({
    required super.id,
    required super.invoiceId,
    required super.inventoryItemId,
    required super.quantity,
    required super.unitCost,
    required super.totalCost,
  });

  factory PurchaseInvoiceItemModel.fromDrift(PurchaseInvoiceItemData data) {
    return PurchaseInvoiceItemModel(
      id: data.id,
      invoiceId: data.invoiceId,
      inventoryItemId: data.inventoryItemId,
      quantity: data.quantity,
      unitCost: data.unitCost,
      totalCost: data.totalCost,
    );
  }
}
