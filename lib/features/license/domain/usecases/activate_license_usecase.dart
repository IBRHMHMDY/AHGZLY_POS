import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/license/domain/repositories/license_repository.dart';

class ActivateLicenseUseCase implements UseCase<void, String> {
  final LicenseRepository repository;

  ActivateLicenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.activateLicense(params);
  }
}