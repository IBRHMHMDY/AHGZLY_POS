import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../../data/models/purchase_invoice_item_model.dart';
import '../entities/purchase_invoice_entity.dart';
import '../repositories/purchases_repository.dart';

class GetPurchaseInvoicesUseCase implements UseCase<List<PurchaseInvoiceEntity>, NoParams> {
  final PurchasesRepository repository;
  GetPurchaseInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PurchaseInvoiceEntity>>> call(NoParams params) async {
    return await repository.getPurchaseInvoices();
  }
}

class SavePurchaseInvoiceParams {
  final int? supplierId;
  final int totalAmount;
  final int paidAmount;
  final String? notes;
  final List<PurchaseInvoiceItemModel> items;

  SavePurchaseInvoiceParams({
    required this.supplierId,
    required this.totalAmount,
    required this.paidAmount,
    required this.notes,
    required this.items,
  });
}

class SavePurchaseInvoiceUseCase implements UseCase<PurchaseInvoiceEntity, SavePurchaseInvoiceParams> {
  final PurchasesRepository repository;
  SavePurchaseInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, PurchaseInvoiceEntity>> call(SavePurchaseInvoiceParams params) async {
    return await repository.savePurchaseInvoice(
      supplierId: params.supplierId,
      totalAmount: params.totalAmount,
      paidAmount: params.paidAmount,
      notes: params.notes,
      items: params.items,
    );
  }
}
