import 'package:ampere/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

/// API-specific exceptions that extend core exceptions
/// These handle HTTP-specific errors and API response errors

/// Exception thrown when API request fails with HTTP error
class ApiException extends ServerException {
  /// HTTP status code
  final int? statusCode;
  
  /// HTTP response data
  final dynamic responseData;
  
  /// HTTP request path
  final String? path;
  
  /// HTTP request method
  final String? method;

  const ApiException({
    required super.message,
    super.code,
    this.statusCode,
    this.responseData,
    this.path,
    this.method,
    super.originalError,
    super.stackTrace,
  });

  /// Creates ApiException from DioException
  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timeout. Please try again.',
          code: dioException.response?.statusCode,
          statusCode: dioException.response?.statusCode,
          responseData: dioException.response?.data,
          path: dioException.requestOptions.path,
          method: dioException.requestOptions.method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(dioException);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          code: -1,
          path: dioException.requestOptions.path,
          method: dioException.requestOptions.method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          code: -1,
          path: dioException.requestOptions.path,
          method: dioException.requestOptions.method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'SSL certificate error. Please try again.',
          code: dioException.response?.statusCode,
          statusCode: dioException.response?.statusCode,
          path: dioException.requestOptions.path,
          method: dioException.requestOptions.method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case DioExceptionType.unknown:
        return ApiException(
          message: dioException.message ?? 'An unexpected error occurred',
          code: dioException.response?.statusCode,
          statusCode: dioException.response?.statusCode,
          responseData: dioException.response?.data,
          path: dioException.requestOptions.path,
          method: dioException.requestOptions.method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );
    }
  }

  /// Handles HTTP response errors based on status code
  static ApiException _handleResponseError(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final responseData = dioException.response?.data;
    final path = dioException.requestOptions.path;
    final method = dioException.requestOptions.method;

    String message = _extractErrorMessage(responseData) ?? 
                     'An error occurred while processing your request';

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message,
          code: statusCode,
          statusCode: statusCode,
          responseData: responseData,
          path: path,
          method: method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 401:
        return ApiException(
          message: message.isNotEmpty ? message : 'Authentication failed. Please login again.',
          code: statusCode,
          statusCode: statusCode,
          responseData: responseData,
          path: path,
          method: method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 403:
        return ApiException(
          message: message.isNotEmpty ? message : 'Access denied. You don\'t have permission.',
          code: statusCode,
          statusCode: statusCode,
          responseData: responseData,
          path: path,
          method: method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 404:
        return ApiException(
          message: message.isNotEmpty ? message : 'Resource not found',
          code: statusCode,
          statusCode: statusCode,
          responseData: responseData,
          path: path,
          method: method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 422:
        // Unprocessable Entity - validation errors
        return ApiException(
          message: message,
          code: statusCode,
          statusCode: statusCode,
          responseData: responseData,
          path: path,
          method: method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 429:
        return ApiException(
          message: message.isNotEmpty ? message : 'Too many requests. Please try again later.',
          code: statusCode,
          statusCode: statusCode,
          responseData: responseData,
          path: path,
          method: method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException(
          message: message.isNotEmpty ? message : 'Server error. Please try again later.',
          code: statusCode,
          statusCode: statusCode,
          responseData: responseData,
          path: path,
          method: method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      default:
        return ApiException(
          message: message,
          code: statusCode,
          statusCode: statusCode,
          responseData: responseData,
          path: path,
          method: method,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );
    }
  }

  /// Extracts error message from API response
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;
    
    if (responseData is Map<String, dynamic>) {
      // Common error message fields
      return responseData['message'] as String? ??
             responseData['error'] as String? ??
             responseData['error_message'] as String? ??
             responseData['msg'] as String?;
    }
    
    if (responseData is String) {
      return responseData;
    }
    
    return null;
  }

  /// Extracts validation errors from API response
  static Map<String, String>? _extractValidationErrors(dynamic responseData) {
    if (responseData == null || responseData is! Map<String, dynamic>) {
      return null;
    }

    final errors = <String, String>{};
    
    // Check for common validation error formats
    if (responseData['errors'] is Map) {
      final errorMap = responseData['errors'] as Map;
      errorMap.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errors[key.toString()] = value.first.toString();
        } else if (value is String) {
          errors[key.toString()] = value;
        }
      });
    }
    
    if (responseData['validation_errors'] is Map) {
      final errorMap = responseData['validation_errors'] as Map;
      errorMap.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errors[key.toString()] = value.first.toString();
        } else if (value is String) {
          errors[key.toString()] = value;
        }
      });
    }

    return errors.isEmpty ? null : errors;
  }
}

/// Extension to convert ApiException to core exceptions
extension ApiExceptionToCoreException on ApiException {
  /// Converts ApiException to appropriate core exception based on status code
  AppException toCoreException() {
    switch (statusCode) {
      case 401:
        return AuthenticationException(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
      
      case 403:
        return AuthorizationException(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
      
      case 404:
        return NotFoundException(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
      
      case 422:
        final errors = ApiException._extractValidationErrors(responseData);
        return ValidationException(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
          errors: errors,
        );
      
      case 408:
      case 504:
        return TimeoutException(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
      
      default:
        // For other status codes, return as ServerException
        return ServerException(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
    }
  }
}

