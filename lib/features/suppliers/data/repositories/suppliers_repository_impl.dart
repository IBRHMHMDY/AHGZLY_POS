import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/suppliers/data/datasources/suppliers_local_data_source.dart';
import 'package:ahgzly_pos/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:ahgzly_pos/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:dartz/dartz.dart';

class SuppliersRepositoryImpl implements SuppliersRepository {
  final SuppliersLocalDataSource localDataSource;

  SuppliersRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers() async {
    try {
      final suppliers = await localDataSource.getSuppliers();
      return Right(suppliers);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, SupplierEntity>> addSupplier(
    SuppliersCompanion supplier,
  ) async {
    try {
      final result = await localDataSource.addSupplier(supplier);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, SupplierEntity>> updateSupplier(
    SuppliersCompanion supplier,
  ) async {
    try {
      final result = await localDataSource.updateSupplier(supplier);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(int id) async {
    try {
      await localDataSource.deleteSupplier(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
