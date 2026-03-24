import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/license/domain/entities/license.dart';
import 'package:ahgzly_pos/features/license/domain/repositories/license_repository.dart';

class CheckLicenseStatusUseCase implements UseCase<License, NoParams> {
  final LicenseRepository repository;

  CheckLicenseStatusUseCase(this.repository);

  @override
  Future<Either<Failure, License>> call(NoParams params) async {
    return await repository.checkLicenseStatus();
  }
}