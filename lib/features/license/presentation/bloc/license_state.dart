import 'package:flutter/foundation.dart';
import 'package:ahgzly_pos/features/license/domain/entities/license.dart';

@immutable
abstract class LicenseState {}

class LicenseInitial extends LicenseState {}

class LicenseLoading extends LicenseState {}

class LicenseValidState extends LicenseState {
  final License license;
  LicenseValidState({required this.license});
}

class LicenseExpiredState extends LicenseState {
  final License license;
  LicenseExpiredState({required this.license});
}

class LicenseActivationSuccessState extends LicenseState {}

class LicenseErrorState extends LicenseState {
  final String message;
  LicenseErrorState({required this.message});
}