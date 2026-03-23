import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String pin;
  LoginEvent(this.pin);
  @override
  List<Object> get props => [pin];
}

class LogoutEvent extends AuthEvent {}