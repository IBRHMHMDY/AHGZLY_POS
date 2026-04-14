import 'package:equatable/equatable.dart';

class LicenseEntity extends Equatable {
  final bool isValid;
  final DateTime? expiryDate;
  final String? deviceId;

  const LicenseEntity({
    required this.isValid,
    this.expiryDate,
    this.deviceId,
  });

  // 🪄 [Refactored]: إضافة دالة مساعدة لحساب الأيام المتبقية للترخيص
  int get remainingDays {
    if (expiryDate == null) return 0;
    final difference = expiryDate!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  @override
  List<Object?> get props => [isValid, expiryDate, deviceId];
}