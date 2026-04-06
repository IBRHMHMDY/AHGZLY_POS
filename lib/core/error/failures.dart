// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class LicenseExpiredFailure extends Failure {
  const LicenseExpiredFailure(super.message);
}

class SecurityFailure extends Failure {
  const SecurityFailure(super.message);
}

// تمت إضافة هذا الكلاس ليتوافق مع نظام الـ Auth الذي بنيناه
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
  
}