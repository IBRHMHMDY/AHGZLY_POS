class License {
  final bool isActivated;
  final bool isTrialExpired;
  final int elapsedDays;
  final String trialStartDate;

  const License({
    required this.isActivated,
    required this.isTrialExpired,
    required this.elapsedDays,
    required this.trialStartDate,
  });
}