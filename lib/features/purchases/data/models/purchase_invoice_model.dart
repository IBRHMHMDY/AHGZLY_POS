import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/purchases/domain/entities/purchase_invoice_entity.dart';

class PurchaseInvoiceModel extends PurchaseInvoiceEntity {
  const PurchaseInvoiceModel({
    required super.id,
    super.supplierId,
    required super.totalAmount,
    required super.paidAmount,
    required super.invoiceDate,
    super.notes,
    required super.createdAt,
  });

  factory PurchaseInvoiceModel.fromDrift(PurchaseInvoiceData data) {
    return PurchaseInvoiceModel(
      id: data.id,
      supplierId: data.supplierId,
      totalAmount: data.totalAmount,
      paidAmount: data.paidAmount,
      invoiceDate: data.invoiceDate,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }
}
