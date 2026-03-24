import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/license/domain/entities/license.dart';

abstract class LicenseRepository {
  Future<Either<Failure, License>> checkLicenseStatus();
  Future<Either<Failure, void>> activateLicense(String licenseKey);
}