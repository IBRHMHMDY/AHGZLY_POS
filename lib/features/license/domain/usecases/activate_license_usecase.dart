import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/license/domain/repositories/license_repository.dart';

// Refactored: Use Params Class
class ActivateLicenseUseCase implements UseCase<void, ActivateLicenseParams> {
  final LicenseRepository repository;

  ActivateLicenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ActivateLicenseParams params) async {
    if (params.licenseKey.trim().isEmpty) {
      return const Left(ValidationFailure('كود التفعيل لا يمكن أن يكون فارغاً.'));
    }
    return await repository.activateLicense(params.licenseKey);
  }
}

class ActivateLicenseParams extends Equatable {
  final String licenseKey;
  const ActivateLicenseParams({required this.licenseKey});

  @override
  List<Object> get props => [licenseKey];
}