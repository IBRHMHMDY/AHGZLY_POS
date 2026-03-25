import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class LicenseRepository {
  Future<Either<Failure, String?>> getSavedLicense();
  Future<Either<Failure, void>> activateLicense(String secureLicenseKey);
}