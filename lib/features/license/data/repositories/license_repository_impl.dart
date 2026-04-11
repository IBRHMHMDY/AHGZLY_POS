import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/license/data/datasources/license_local_data_source.dart';
import 'package:ahgzly_pos/features/license/domain/repositories/license_repository.dart';
import 'package:dartz/dartz.dart';

class LicenseRepositoryImpl implements LicenseRepository {
  final LicenseLocalDataSource localDataSource;

  LicenseRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, String?>> getSavedLicense() async {
    try {
      final licenseToken = await localDataSource.getSavedLicense();
      return Right(licenseToken);
    } catch (_) {
      // Refactored: Arabic user-friendly error
      return const Left(CacheFailure('فشل في قراءة بيانات الترخيص من الذاكرة الآمنة.'));
    }
  }

  @override
  Future<Either<Failure, void>> activateLicense(String secureLicenseKey) async {
    try {
      await localDataSource.saveLicense(secureLicenseKey);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('فشل في حفظ بيانات الترخيص.'));
    }
  }
}