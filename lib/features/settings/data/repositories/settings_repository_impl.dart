import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ahgzly_pos/features/settings/data/models/app_settings_model.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';
import 'package:ahgzly_pos/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppSettingsEntity>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } on LocalDatabaseException catch (_) {
      // Refactored: Clear Arabic messaging
      return const Left(DatabaseFailure('حدث خطأ أثناء جلب الإعدادات. يرجى المحاولة لاحقاً.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(AppSettingsEntity settings) async {
    try {
      // Mapping Entity to Model before sending to Data Source
      final model = AppSettingsModel(
        taxRate: settings.taxRate,
        serviceRate: settings.serviceRate,
        deliveryFee: settings.deliveryFee,
        printerName: settings.printerName,
        restaurantName: settings.restaurantName,
        taxNumber: settings.taxNumber,
        printMode: settings.printMode,
      );
      
      await localDataSource.updateSettings(model);
      return const Right(null);
    } on LocalDatabaseException catch (_) {
      return const Left(DatabaseFailure('فشل في حفظ الإعدادات. تأكد من مساحة التخزين.'));
    }
  }
}