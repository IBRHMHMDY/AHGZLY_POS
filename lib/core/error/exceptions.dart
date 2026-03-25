// lib/core/error/exceptions.dart

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}