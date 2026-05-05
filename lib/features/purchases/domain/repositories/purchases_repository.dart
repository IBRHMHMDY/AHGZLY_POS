import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/purchase_invoice_entity.dart';
import '../../data/models/purchase_invoice_item_model.dart';

abstract class PurchasesRepository {
  Future<Either<Failure, List<PurchaseInvoiceEntity>>> getPurchaseInvoices();
  Future<Either<Failure, PurchaseInvoiceEntity>> savePurchaseInvoice({
    required int? supplierId,
    required int totalAmount,
    required int paidAmount,
    required String? notes,
    required List<PurchaseInvoiceItemModel> items,
  });
}
