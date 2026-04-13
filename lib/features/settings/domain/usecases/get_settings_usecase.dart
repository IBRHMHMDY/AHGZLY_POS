import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/repositories/settings_repository.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';
import 'package:dartz/dartz.dart';

// Refactored: Implement UseCase with NoParams
class GetSettingsUseCase implements UseCase<AppSettingsEntity, NoParams> {
  final SettingsRepository repository;
  GetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, AppSettingsEntity>> call(NoParams params) async {
    return await repository.getSettings();
  }
}