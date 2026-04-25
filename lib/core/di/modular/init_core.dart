// ==========================================
// Core & Security Registrations
// ==========================================
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/services/backup_service.dart';
import 'package:ahgzly_pos/core/services/printer_service.dart';
import 'package:ahgzly_pos/core/services/security/crypto_service.dart';
import 'package:ahgzly_pos/core/services/security/device_security_service.dart';
import 'package:ahgzly_pos/core/services/security/time_guard_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void initCore() {
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase(openConnection('pos_sys_drift.db')),
  );
  sl.registerLazySingleton<PrinterService>(() => PrinterService());
  sl.registerLazySingleton<BackupService>(
    () => BackupService(),
  ); // 🪄 تم تسجيل الخدمة بنجاح
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<CryptoService>(() => CryptoService());
  sl.registerLazySingleton<DeviceSecurityService>(
    () => DeviceSecurityService(sl()),
  );
  sl.registerLazySingleton<TimeGuardService>(() => TimeGuardService(sl()));
}