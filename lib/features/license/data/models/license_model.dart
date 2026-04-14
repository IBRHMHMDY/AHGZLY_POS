import 'package:ahgzly_pos/features/license/domain/entities/license_entity.dart';

class LicenseModel extends LicenseEntity {
  const LicenseModel({
    required super.isValid,
    super.expiryDate,
    super.deviceId,
  });

  // 🪄 [Refactored]: قراءة البيانات من الـ JSON (الـ Payload بعد فك التشفير)
  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      isValid: json['is_valid'] == 1 || json['is_valid'] == true || json['is_activated'] == true,
      expiryDate: json['expiry_date'] != null 
          ? DateTime.tryParse(json['expiry_date'] as String) 
          : null,
      deviceId: json['device_id'] as String?,
    );
  }

  // 🪄 [Refactored]: تحويل البيانات إذا لزم الأمر لحفظها محلياً
  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'expiry_date': expiryDate?.toIso8601String(),
      'device_id': deviceId,
    };
  }
}