import 'package:ampere/core/api/api_client.dart';
import 'package:dio/dio.dart';

/// Provider for ApiClient singleton instance
/// Ensures only one instance of ApiClient is created and shared across the app
/// 
/// @deprecated This class is deprecated in favor of GetIt dependency injection.
/// Use `Injection.apiClient` instead to get the ApiClient instance.
/// This class is kept for backward compatibility but should not be used in new code.
@Deprecated('Use Injection.apiClient from dependency injection instead')
class ApiClientProvider {
  static ApiClient? _instance;

  /// Gets or creates the ApiClient singleton instance
  /// 
  /// [baseUrl] - Base URL for API requests (defaults to EnvConfig.apiBaseUrl)
  /// [timeout] - Request timeout in milliseconds (default: 30 seconds)
  /// [headers] - Default headers to include in all requests
  /// [interceptors] - Additional interceptors to add
  static ApiClient getInstance({
    String? baseUrl,
    Duration? timeout,
    Map<String, dynamic>? headers,
    List<Interceptor>? interceptors,
  }) {
    _instance ??= ApiClient(
      baseUrl: baseUrl,
      timeout: timeout,
      headers: headers,
      interceptors: interceptors,
    );
    return _instance!;
  }

  /// Initializes the ApiClient with default configuration
  /// Should be called during app initialization
  static ApiClient initialize({
    String? baseUrl,
    Duration? timeout,
    Map<String, dynamic>? headers,
    List<Interceptor>? interceptors,
  }) {
    return getInstance(
      baseUrl: baseUrl,
      timeout: timeout,
      headers: headers,
      interceptors: interceptors,
    );
  }

  /// Gets the current ApiClient instance
  /// Throws an error if not initialized
  static ApiClient get instance {
    if (_instance == null) {
      throw StateError(
        'ApiClient not initialized. Call ApiClientProvider.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Resets the ApiClient instance (useful for testing)
  static void reset() {
    _instance = null;
  }

  /// Checks if ApiClient is initialized
  static bool get isInitialized => _instance != null;
}

