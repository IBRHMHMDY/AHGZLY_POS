import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/repositories/settings_repository.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';
import 'package:dartz/dartz.dart';

// Refactored: Implement UseCase with NoParams
class GetSettingsUseCase implements UseCase<AppSettings, NoParams> {
  final SettingsRepository repository;
  GetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, AppSettings>> call(NoParams params) async {
    return await repository.getSettings();
  }
}