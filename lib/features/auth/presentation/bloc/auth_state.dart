import 'package:ahgzly_pos/core/common/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated({required this.user});
  @override List<Object> get props => [user];
}

// Refactored: Added specific state for unlocking the screen
class AuthUnlocked extends AuthState {
  final User user;
  AuthUnlocked({required this.user});
  @override List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
  @override List<Object> get props => [message];
}