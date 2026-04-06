import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

class LoadUsersEvent extends UsersEvent {}

class AddUserEvent extends UsersEvent {
  final String name;
  final String role;
  final String pin;

  const AddUserEvent({required this.name, required this.role, required this.pin});

  @override
  List<Object> get props => [name, role, pin];
}

class ToggleUserStatusEvent extends UsersEvent {
  final int id;
  final bool isActive;

  const ToggleUserStatusEvent({required this.id, required this.isActive});

  @override
  List<Object> get props => [id, isActive];
}