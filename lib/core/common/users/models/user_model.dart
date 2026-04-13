import 'package:ahgzly_pos/core/database/app_database.dart'; // [Added]
import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:ahgzly_pos/core/extensions/user_role.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.role,
    required super.isActive,
  });

  // [Refactored]: قراءة آمنة ومباشرة من كائن Drift
  factory UserModel.fromDrift(UserData data) {
    return UserModel(
      id: data.id,
      name: data.name,
      role: UserRoleExtension.fromValue(data.role), // تحويل النص إلى Enum
      isActive: data.isActive,
    );
  }
}