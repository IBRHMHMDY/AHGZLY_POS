import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/license/domain/entities/license_entity.dart'; // 🪄 استيراد الكيان الجديد

abstract class LicenseState extends Equatable {
  const LicenseState();
  
  @override
  List<Object> get props => [];
}

class LicenseInitial extends LicenseState {}

class LicenseLoading extends LicenseState {}

// 🪄 [Refactored]: إضافة LicenseEntity للحالة لكي نستفيد من الأيام المتبقية
class LicenseValidState extends LicenseState {
  final LicenseEntity license;
  const LicenseValidState({required this.license});

  @override
  List<Object> get props => [license];
}

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