import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';

extension UserRoleExtension on UserRole {
  String toValue() => name;

  String toDisplayName() {
    switch (this) {
      case UserRole.admin:
        return 'مدير نظام (Admin)';
      case UserRole.cashier:
        return 'كاشير (Cashier)';
    }
  }

  static UserRole fromValue(String val) {
    return UserRole.values.firstWhere(
      (e) => e.name == val,
      orElse: () => UserRole.cashier,
    );
  }
}