import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/supplier_entity.dart';
import '../repositories/suppliers_repository.dart';

class GetSuppliersUseCase implements UseCase<List<SupplierEntity>, NoParams> {
  final SuppliersRepository repository;
  GetSuppliersUseCase(this.repository);

  @override
  Future<Either<Failure, List<SupplierEntity>>> call(NoParams params) async {
    return await repository.getSuppliers();
  }
}

class AddSupplierUseCase implements UseCase<SupplierEntity, SuppliersCompanion> {
  final SuppliersRepository repository;
  AddSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, SupplierEntity>> call(SuppliersCompanion params) async {
    return await repository.addSupplier(params);
  }
}

class UpdateSupplierUseCase implements UseCase<SupplierEntity, SuppliersCompanion> {
  final SuppliersRepository repository;
  UpdateSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, SupplierEntity>> call(SuppliersCompanion params) async {
    return await repository.updateSupplier(params);
  }
}

class DeleteSupplierUseCase implements UseCase<void, int> {
  final SuppliersRepository repository;
  DeleteSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteSupplier(id);
  }
}
