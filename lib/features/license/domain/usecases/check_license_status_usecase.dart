import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart'; 
import '../../../../core/services/security/crypto_service.dart';
import '../../../../core/services/security/device_security_service.dart';
import '../../../../core/services/security/time_guard_service.dart';
import '../repositories/license_repository.dart';
import '../entities/license_entity.dart';

class CheckLicenseStatusUseCase implements UseCase<LicenseEntity, NoParams> {
  final LicenseRepository repository;
  final CryptoService cryptoService;
  final DeviceSecurityService deviceSecurityService;
  final TimeGuardService timeGuardService;

  CheckLicenseStatusUseCase({
    required this.repository,
    required this.cryptoService,
    required this.deviceSecurityService,
    required this.timeGuardService,
  });

  @override
  Future<Either<Failure, LicenseEntity>> call(NoParams params) async {
    final encodedLicenseEither = await repository.getSavedLicense();
    
    return encodedLicenseEither.fold(
      (failure) => Left(failure),
      (encodedLicense) async {
        // 🪄 [Refactored]: التأكد من وجود ترخيص أولاً قبل فحص الوقت
        if (encodedLicense == null || encodedLicense.isEmpty) {
          return const Right(LicenseEntity(isValid: false)); 
        }

        // 🪄 [Refactored]: فحص التلاعب بالوقت يتم هنا للترخيص الفعال فقط
        final isTampered = await timeGuardService.isTimeTampered();
        if (isTampered) {
          return const Left(SecurityFailure('تم اكتشاف تلاعب في وقت النظام. تم إيقاف الترخيص أمنياً.'));
        }

        final payload = cryptoService.decodeAndVerifyLicense(encodedLicense);
        if (payload == null) {
          return const Left(SecurityFailure('بيانات الترخيص غير صالحة أو تم التلاعب بها.'));
        }

        final currentDeviceId = await deviceSecurityService.getUniqueDeviceId();
        if (payload['device_id'] != currentDeviceId) {
          return const Left(SecurityFailure('هذا الترخيص مخصص لجهاز آخر ولا يمكن استخدامه هنا.'));
        }

        final expiryDate = DateTime.parse(payload['expiry_date']);
        if (DateTime.now().isAfter(expiryDate)) {
          return const Left(LicenseExpiredFailure('لقد انتهت صلاحية الترخيص الخاص بك. يرجى التجديد.'));
        }

        return Right(LicenseEntity(
          isValid: true,
          expiryDate: expiryDate,
          deviceId: payload['device_id'],
        ));
      },
    );
  }
}