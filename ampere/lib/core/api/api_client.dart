import 'package:ampere/core/api/api_exceptions.dart';
import 'package:ampere/core/api/logging_interceptor.dart';
import 'package:ampere/core/config/env_config.dart';
import 'package:dio/dio.dart';

/// API Client using Dio for HTTP requests
/// Handles error conversion, logging, and request configuration
class ApiClient {
  late final Dio _dio;
  String? _authToken;

  /// Creates an ApiClient instance
  /// 
  /// [baseUrl] - Base URL for API requests (defaults to EnvConfig.apiBaseUrl)
  /// [timeout] - Request timeout in milliseconds (default: 30000)
  /// [headers] - Default headers to include in all requests
  /// [interceptors] - Additional interceptors to add
  ApiClient({
    String? baseUrl,
    Duration? timeout,
    Map<String, dynamic>? headers,
    List<Interceptor>? interceptors,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? EnvConfig.apiBaseUrl,
        connectTimeout: timeout ?? const Duration(seconds: 30),
        receiveTimeout: timeout ?? const Duration(seconds: 30),
        sendTimeout: timeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
      ),
    );

    // Add logging interceptor (only in dev mode)
    _dio.interceptors.add(LoggingInterceptor());

    // Add custom interceptors if provided
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }

    // Note: Error conversion is handled in each method's try-catch block
    // to avoid circular error handling
  }

  /// Sets the authentication token for subsequent requests
  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Gets the current authentication token
  String? get authToken => _authToken;

  /// Clears the authentication token
  void clearAuthToken() {
    setAuthToken(null);
  }

  /// Updates default headers
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Removes a header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Performs a GET request
  /// 
  /// [path] - API endpoint path
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a POST request
  /// 
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a PUT request
  /// 
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a PATCH request
  /// 
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Performs a DELETE request
  /// 
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Query parameters
  /// [options] - Additional request options
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Downloads a file
  /// 
  /// [url] - File URL to download
  /// [savePath] - Path to save the file
  /// [onReceiveProgress] - Progress callback
  Future<Response> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Uploads a file
  /// 
  /// [path] - API endpoint path
  /// [filePath] - Path to the file to upload
  /// [onSendProgress] - Progress callback
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath),
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Gets the underlying Dio instance (for advanced usage)
  Dio get dio => _dio;
}

