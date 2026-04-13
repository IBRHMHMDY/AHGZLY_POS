import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppSettingsEntity>> getSettings();
  Future<Either<Failure, void>> updateSettings(AppSettingsEntity settings);
}