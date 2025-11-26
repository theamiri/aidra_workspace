import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the application
/// Following clean architecture principles for error handling
/// Failures are used in the domain layer and are converted from exceptions
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure related to server/API communication
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Failure related to network connectivity
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Failure related to caching operations
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Failure related to data format issues
class FormatFailure extends Failure {
  const FormatFailure({required super.message, super.code});
}

/// Failure related to authentication
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code});
}

/// Failure related to authorization (permission denied)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required super.message, super.code});
}

/// Failure when a requested resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

/// Failure related to input validation
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({required super.message, super.code, this.errors});

  @override
  List<Object?> get props => [message, code, errors];
}

/// Failure when a timeout occurs
class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, super.code});
}

/// Generic failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.code});
}
