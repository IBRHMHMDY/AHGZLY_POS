// ==========================================
// Features Registrations
// ==========================================
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/features/license/data/datasources/license_local_data_source.dart';
import 'package:ahgzly_pos/features/license/data/repositories/license_repository_impl.dart';
import 'package:ahgzly_pos/features/license/domain/repositories/license_repository.dart';
import 'package:ahgzly_pos/features/license/domain/usecases/activate_license_usecase.dart';
import 'package:ahgzly_pos/features/license/domain/usecases/check_license_status_usecase.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_bloc.dart';

void initLicense() {
  sl.registerLazySingleton<LicenseLocalDataSource>(
    () => LicenseLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<LicenseRepository>(
    () => LicenseRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(
    () => CheckLicenseStatusUseCase(
      cryptoService: sl(),
      deviceSecurityService: sl(),
      repository: sl(),
      timeGuardService: sl(),
    ),
  );
  sl.registerLazySingleton(() => ActivateLicenseUseCase(sl()));
  sl.registerFactory(
    () => LicenseBloc(
      checkLicenseStatusUseCase: sl(),
      activateLicenseUseCase: sl(),
    ),
  );
}