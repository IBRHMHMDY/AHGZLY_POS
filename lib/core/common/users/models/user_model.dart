import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart'; // المسار الجديد

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.role,
    required super.isActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: map['name'] as String,
      role: map['role'] as String,
      isActive: (map['is_active'] as int) == 1, 
    );
  }
}