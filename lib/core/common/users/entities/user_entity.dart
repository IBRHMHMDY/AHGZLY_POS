import 'package:ahgzly_pos/core/extensions/user_role.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final UserRole role; // [Refactored]: تغيير من String إلى Enum
  final bool isActive; 

  const User({
    required this.id,
    required this.name,
    required this.role,
    this.isActive = true, 
  });

  bool get isAdmin => role == UserRole.admin; // [Refactored]: تحقق آمن عبر الـ Enum

  @override
  List<Object?> get props => [id, name, role, isActive];
}