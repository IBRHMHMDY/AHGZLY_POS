import 'package:flutter/foundation.dart';

@immutable
abstract class LicenseEvent {}

class CheckLicenseEvent extends LicenseEvent {}

class ActivateLicenseSubmitEvent extends LicenseEvent {
  final String licenseKey;

  ActivateLicenseSubmitEvent({required this.licenseKey});
}