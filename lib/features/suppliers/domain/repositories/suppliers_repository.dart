import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/supplier_entity.dart';

abstract class SuppliersRepository {
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers();
  Future<Either<Failure, SupplierEntity>> addSupplier(SuppliersCompanion supplier);
  Future<Either<Failure, SupplierEntity>> updateSupplier(SuppliersCompanion supplier);
  Future<Either<Failure, void>> deleteSupplier(int id);
}
