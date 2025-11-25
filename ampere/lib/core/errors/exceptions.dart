/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exception thrown when server returns an error response
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when data format is invalid
class FormatException extends AppException {
  const FormatException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when authorization fails (permission denied)
class AuthorizationException extends AppException {
  const AuthorizationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when a requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when input validation fails
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.errors,
  });
}

/// Exception thrown when a timeout occurs
class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown for unexpected errors
class UnexpectedException extends AppException {
  const UnexpectedException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

