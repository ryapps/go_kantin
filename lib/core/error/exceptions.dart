/// Base class for all exceptions
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Server/Firebase related exceptions
class ServerException extends AppException {
  ServerException(super.message);
}

/// Cache related exceptions
class CacheException extends AppException {
  CacheException(super.message);
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(super.message);
}

/// Validation related exceptions
class ValidationException extends AppException {
  ValidationException(super.message);
}

/// Permission/Authorization exceptions
class PermissionException extends AppException {
  PermissionException(super.message);
}

/// Not found exceptions
class NotFoundException extends AppException {
  NotFoundException(super.message);
}

/// Business logic exceptions
class BusinessLogicException extends AppException {
  BusinessLogicException(super.message);
}