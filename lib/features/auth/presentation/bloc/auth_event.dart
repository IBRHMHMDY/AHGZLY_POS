import 'package:ahgzly_pos/core/common/users/entities/user_entity.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String pin;
  LoginSubmittedEvent({required this.pin});
}

// Refactored: Added event to handle lock screen logic inside the BLoC
class UnlockSubmittedEvent extends AuthEvent {
  final String pin;
  final User currentUser;
  UnlockSubmittedEvent({required this.pin, required this.currentUser});
}

class LogoutEvent extends AuthEvent {}
