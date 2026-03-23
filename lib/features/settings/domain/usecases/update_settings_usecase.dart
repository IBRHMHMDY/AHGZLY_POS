import 'package:dartz/dartz.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';
import 'package:ahgzly_pos/features/settings/domain/repositories/settings_repository.dart';

class UpdateSettingsUseCase implements UseCase<void, AppSettings> {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AppSettings settings) {
    return repository.updateSettings(settings);
  }
}