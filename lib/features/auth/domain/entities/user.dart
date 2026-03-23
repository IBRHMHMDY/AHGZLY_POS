import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String role; // 'admin' or 'cashier'

  const User({
    required this.id,
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, name, role];
}