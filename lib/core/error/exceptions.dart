/// Base Exception for the application to allow catching general app exceptions if needed
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class SecurityException extends AppException {
  SecurityException(super.message);
}

class CacheException extends AppException {
  CacheException(super.message);
}

class LocalDatabaseException extends AppException {
  LocalDatabaseException(super.message);
}

class PrinterException extends AppException {
  PrinterException(super.message);
}