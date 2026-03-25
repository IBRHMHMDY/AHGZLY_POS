import 'package:flutter/foundation.dart';

@immutable
abstract class LicenseState {}

class LicenseInitial extends LicenseState {}

class LicenseLoading extends LicenseState {}

class LicenseValidState extends LicenseState {}

// تم دمج حالات الانتهاء والتلاعب في حالة واحدة للرفض مع تمرير السبب
class LicenseInvalidState extends LicenseState {
  final String message;
  LicenseInvalidState({required this.message});
}

class LicenseActivationSuccessState extends LicenseState {}

class LicenseErrorState extends LicenseState {
  final String message;
  LicenseErrorState({required this.message});
}