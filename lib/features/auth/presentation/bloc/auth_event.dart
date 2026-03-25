import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String pin;
  LoginSubmittedEvent({required this.pin});
}

class LogoutEvent extends AuthEvent {}