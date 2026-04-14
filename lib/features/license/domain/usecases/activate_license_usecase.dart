import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/license/domain/repositories/license_repository.dart';
import 'package:ahgzly_pos/core/services/security/crypto_service.dart'; // 🪄 استيراد جديد
import 'package:ahgzly_pos/core/services/security/device_security_service.dart'; // 🪄 استيراد جديد

class ActivateLicenseUseCase implements UseCase<void, ActivateLicenseParams> {
  final LicenseRepository repository;
  final CryptoService cryptoService; // 🪄 إضافة
  final DeviceSecurityService deviceSecurityService; // 🪄 إضافة

  ActivateLicenseUseCase({
    required this.repository,
    required this.cryptoService,
    required this.deviceSecurityService,
  });

  @override
  Future<Either<Failure, void>> call(ActivateLicenseParams params) async {
    if (params.licenseKey.trim().isEmpty) {
      return const Left(ValidationFailure('كود التفعيل لا يمكن أن يكون فارغاً.'));
    }

    // 🪄 [Refactored]: التحقق من صحة التشفير قبل الحفظ في الذاكرة
    final payload = cryptoService.decodeAndVerifyLicense(params.licenseKey);
    if (payload == null) {
      return const Left(SecurityFailure('كود التفعيل غير صالح أو تم التلاعب به.'));
    }

    // 🪄 [Refactored]: التحقق من أن الترخيص مرتبط بهذا الجهاز تحديداً
    final currentDeviceId = await deviceSecurityService.getUniqueDeviceId();
    if (payload['device_id'] != currentDeviceId) {
      return const Left(SecurityFailure('هذا الترخيص مخصص لجهاز آخر ولا يمكن استخدامه على هذا الجهاز.'));
    }

    // إذا كان كل شيء سليماً، نقوم بحفظه
    return await repository.activateLicense(params.licenseKey);
  }
}

class ActivateLicenseParams extends Equatable {
  final String licenseKey;
  const ActivateLicenseParams({required this.licenseKey});

  @override
  List<Object> get props => [licenseKey];
}