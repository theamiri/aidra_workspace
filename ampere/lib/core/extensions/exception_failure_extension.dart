import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';

/// Extension to convert exceptions to failures
/// This follows clean architecture where exceptions (data layer) are converted to failures (domain layer)
extension ExceptionToFailure on AppException {
  /// Converts an AppException to its corresponding Failure
  ///
  /// All AppException types are explicitly handled.
  /// If a new AppException type is added, this switch statement must be updated.
  /// The default case should never be reached, but is included for exhaustiveness checking
  /// and to provide a clear error if a new exception type is added without updating this method.
  Failure toFailure() {
    switch (this) {
      case ServerException _:
        return ServerFailure(message: message, code: code);
      case NetworkException _:
        return NetworkFailure(message: message, code: code);
      case CacheException _:
        return CacheFailure(message: message, code: code);
      case FormatException _:
        return FormatFailure(message: message, code: code);
      case AuthenticationException _:
        return AuthenticationFailure(message: message, code: code);
      case AuthorizationException _:
        return AuthorizationFailure(message: message, code: code);
      case NotFoundException _:
        return NotFoundFailure(message: message, code: code);
      case ValidationException validationException:
        return ValidationFailure(
          message: message,
          code: code,
          errors: validationException.errors,
        );
      case TimeoutException _:
        return TimeoutFailure(message: message, code: code);
      case UnexpectedException _:
        return UnexpectedFailure(message: message, code: code);
      default:
        // This should never be reached if all AppException types are handled above.
        // If this is reached, a new AppException type was added without updating this method.
        throw StateError(
          'Unhandled AppException type: ${runtimeType}. '
          'Please update ExceptionToFailure.toFailure() to handle this exception type.',
        );
    }
  }
}
