import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/repositories/settings_repository.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Refactored: Implement UseCase and add validation logic
class UpdateSettingsUseCase implements UseCase<void, UpdateSettingsParams> {
  final SettingsRepository repository;
  UpdateSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateSettingsParams params) async {
    // 🛡️ حماية مالية: لا يمكن أن تكون الضرائب أو رسوم التوصيل بالسالب
    if (params.settings.taxRate < 0 || params.settings.serviceRate < 0 || params.settings.deliveryFee < 0) {
      return const Left(ValidationFailure('لا يمكن أن تكون نسب الضرائب، الخدمة، أو التوصيل بالسالب'));
    }
    
    return await repository.updateSettings(params.settings);
  }
}

class UpdateSettingsParams extends Equatable {
  final AppSettingsEntity settings;

  const UpdateSettingsParams({required this.settings});

  @override
  List<Object> get props => [settings];
}