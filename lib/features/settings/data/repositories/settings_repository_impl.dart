import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ahgzly_pos/features/settings/data/models/app_settings_model.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';
import 'package:ahgzly_pos/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(DatabaseFailure('فشل في جلب الإعدادات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(AppSettings settings) async {
    try {
      final settingsModel = AppSettingsModel.fromEntity(settings);
      await localDataSource.updateSettings(settingsModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('فشل في تحديث الإعدادات: ${e.toString()}'));
    }
  }
}