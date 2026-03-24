import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/license/data/datasources/license_local_data_source.dart';
import 'package:ahgzly_pos/features/license/domain/entities/license.dart';
import 'package:ahgzly_pos/features/license/domain/repositories/license_repository.dart';

class LicenseRepositoryImpl implements LicenseRepository {
  final LicenseLocalDataSource localDataSource;

  LicenseRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, License>> checkLicenseStatus() async {
    try {
      final licenseModel = await localDataSource.checkLicenseStatus();
      return Right(licenseModel);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> activateLicense(String licenseKey) async {
    try {
      await localDataSource.activateLicense(licenseKey);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}