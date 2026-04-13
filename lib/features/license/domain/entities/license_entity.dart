import 'package:equatable/equatable.dart';

class LicenseEntity extends Equatable {
  final bool isActivated;
  final bool isTrialExpired;
  final int elapsedDays;
  final DateTime trialStartDate; // [Refactored]: تغيير إلى DateTime

  const LicenseEntity({
    required this.isActivated,
    required this.isTrialExpired,
    required this.elapsedDays,
    required this.trialStartDate,
  });

  @override
  List<Object?> get props => [isActivated, isTrialExpired, elapsedDays, trialStartDate];
}