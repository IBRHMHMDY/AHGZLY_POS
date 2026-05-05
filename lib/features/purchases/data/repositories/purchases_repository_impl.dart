import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/purchases/domain/entities/purchase_invoice_entity.dart';
import 'package:ahgzly_pos/features/purchases/domain/repositories/purchases_repository.dart';
import 'package:dartz/dartz.dart';
import '../datasources/purchases_local_data_source.dart';
import '../models/purchase_invoice_item_model.dart';

class PurchasesRepositoryImpl implements PurchasesRepository {
  final PurchasesLocalDataSource localDataSource;

  PurchasesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<PurchaseInvoiceEntity>>> getPurchaseInvoices() async {
    try {
      final invoices = await localDataSource.getPurchaseInvoices();
      return Right(invoices);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, PurchaseInvoiceEntity>> savePurchaseInvoice({
    required int? supplierId,
    required int totalAmount,
    required int paidAmount,
    required String? notes,
    required List<PurchaseInvoiceItemModel> items,
  }) async {
    try {
      final result = await localDataSource.savePurchaseInvoice(
        supplierId: supplierId,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        notes: notes,
        items: items,
      );
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
