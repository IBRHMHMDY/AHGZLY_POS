import 'package:ahgzly_pos/features/license/domain/entities/license_entity.dart';

class LicenseModel extends LicenseEntity {
  const LicenseModel({
    required super.isActivated,
    required super.isTrialExpired,
    required super.elapsedDays,
    required super.trialStartDate,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json, int calculatedElapsedDays, bool calculatedIsTrialExpired) {
    return LicenseModel(
      isActivated: json['is_activated'] == 1,
      isTrialExpired: calculatedIsTrialExpired,
      elapsedDays: calculatedElapsedDays,
      trialStartDate: json['trial_start_date'] as String,
    );
  }
}