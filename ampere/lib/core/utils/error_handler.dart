import 'package:ampere/core/api/api_exceptions.dart';
import 'package:ampere/core/errors/exceptions.dart' as app_exceptions;
import 'package:dio/dio.dart';

/// Utility class for handling errors in data sources
/// Converts API, network, cache, and other errors to appropriate app exceptions
class ErrorHandler {
  /// Handles errors for remote data sources (API calls)
  /// Converts API and network errors to appropriate app exceptions
  /// 
  /// [error] - The error that occurred
  /// [stackTrace] - The stack trace of the error
  /// [operation] - The operation name for context in error messages
  /// 
  /// Throws appropriate app exception based on error type
  static Never handleRemoteError(
    dynamic error,
    StackTrace stackTrace,
    String operation,
  ) {
    if (error is ApiException) {
      final coreException = error.toCoreException();
      // Re-throw specific exceptions as-is
      if (coreException is app_exceptions.AuthenticationException ||
          coreException is app_exceptions.AuthorizationException ||
          coreException is app_exceptions.NotFoundException ||
          coreException is app_exceptions.ValidationException ||
          coreException is app_exceptions.TimeoutException) {
        throw coreException;
      }
      // Convert other exceptions to ServerException
      throw app_exceptions.ServerException(
        message: coreException.message,
        code: coreException.code,
        originalError: coreException.originalError,
        stackTrace: coreException.stackTrace,
      );
    }

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw app_exceptions.NetworkException(
          message: 'Network error: ${error.message ?? "Connection failed"}',
          originalError: error,
          stackTrace: stackTrace,
        );
      }
      throw app_exceptions.ServerException(
        message: 'Server error: ${error.message ?? "Unknown error"}',
        code: error.response?.statusCode,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    throw app_exceptions.UnexpectedException(
      message: 'Unexpected error during $operation: $error',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handles errors for local data sources (cache/storage operations)
  /// Converts storage and parsing errors to appropriate app exceptions
  /// 
  /// [error] - The error that occurred
  /// [stackTrace] - The stack trace of the error
  /// [operation] - The operation name for context in error messages
  /// 
  /// Throws appropriate app exception based on error type
  static Never handleLocalError(
    dynamic error,
    StackTrace stackTrace,
    String operation,
  ) {
    // Handle JSON parsing errors (Dart's built-in FormatException)
    if (error is FormatException) {
      throw app_exceptions.FormatException(
        message: 'Failed to parse data during $operation: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Re-throw app exceptions as-is
    if (error is app_exceptions.CacheException ||
        error is app_exceptions.FormatException) {
      throw error;
    }

    // Default to CacheException for storage-related errors
    throw app_exceptions.CacheException(
      message: 'Failed to $operation: $error',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Generic error handler that can be used for any data source
  /// Automatically detects error type and handles accordingly
  /// 
  /// [error] - The error that occurred
  /// [stackTrace] - The stack trace of the error
  /// [operation] - The operation name for context in error messages
  /// [isRemote] - Whether this is a remote (API) or local (cache) operation
  /// 
  /// Throws appropriate app exception based on error type
  static Never handleError(
    dynamic error,
    StackTrace stackTrace,
    String operation, {
    bool isRemote = true,
  }) {
    if (isRemote) {
      handleRemoteError(error, stackTrace, operation);
    } else {
      handleLocalError(error, stackTrace, operation);
    }
  }
}

