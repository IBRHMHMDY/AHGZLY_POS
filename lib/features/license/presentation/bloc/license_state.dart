import 'package:equatable/equatable.dart';

abstract class LicenseState extends Equatable {
  const LicenseState();
  
  @override
  List<Object> get props => [];
}

class LicenseInitial extends LicenseState {}

class LicenseLoading extends LicenseState {}

class LicenseValidState extends LicenseState {}

class LicenseInvalidState extends LicenseState {
  final String message;
  const LicenseInvalidState({required this.message});
  
  @override
  List<Object> get props => [message];
}

class LicenseActivationSuccessState extends LicenseState {}

class LicenseErrorState extends LicenseState {
  final String message;
  const LicenseErrorState({required this.message});
  
  @override
  List<Object> get props => [message];
}