import 'dart:async';
import 'package:ampere/core/api/api_client.dart';
import 'package:ampere/core/api/api_endpoints.dart';
import 'package:ampere/core/config/env_config.dart';
import 'package:ampere/core/utils/jwt_utils.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ampere/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_event.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// A safer, more robust Auth Interceptor.
/// Handles token refresh, queues failed requests,
/// resends them when refresh succeeds, and signs out on failure.
class AuthInterceptor extends Interceptor {
  final RefreshTokenUseCase _refreshTokenUseCase;
  final ApiClient _apiClient;
  final AuthBloc _authBloc;
  final AuthRepository _authRepository;
  final Logger _logger;

  AuthInterceptor({
    required RefreshTokenUseCase refreshTokenUseCase,
    required ApiClient apiClient,
    required AuthBloc authBloc,
    required AuthRepository authRepository,
  }) : _refreshTokenUseCase = refreshTokenUseCase,
       _apiClient = apiClient,
       _authBloc = authBloc,
       _authRepository = authRepository,
       _logger = Logger(
         printer: PrettyPrinter(
           methodCount: 0,
           errorMethodCount: 3,
           lineLength: 120,
           colors: true,
           printEmojis: true,
         ),
         level: EnvConfig.isProduction ? Level.nothing : Level.error,
       );

  // Endpoints that do NOT trigger refresh
  static const List<String> _excluded = [
    ApiEndpoints.login,
    ApiEndpoints.refreshToken,
    ApiEndpoints.logout,
  ];

  // Only one refresh process at a time
  Future<bool>? _refreshFuture;

  // Flag to prevent race conditions when setting/resetting _refreshFuture
  bool _isRefreshing = false;

  // Queue of requests waiting for refresh
  final List<_QueuedRequest> _queue = [];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Not a 401 → ignore
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // For login/logout/refresh → do not try to refresh
    if (_isExcluded(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Start or attach to the shared refresh future (thread-safe)
    // Use atomic check-and-set to prevent race conditions
    if (!_isRefreshing && _refreshFuture == null) {
      _isRefreshing = true;
      _refreshFuture = _refreshToken().whenComplete(() {
        // Reset atomically to allow next refresh
        _isRefreshing = false;
        _refreshFuture = null;
      });
    }

    // Queue this request until refresh completes
    final result = await _queueRequest(err);

    // If refresh failed → propagate error
    if (!result) {
      return handler.next(err);
    }

    /// At this point refresh was successful → retry request
    try {
      final response = await _retry(err.requestOptions);
      return handler.resolve(response);
    } catch (e, stackTrace) {
      // Log the new error for debugging
      _logger.e(
        'Request retry failed after successful token refresh',
        error: e,
        stackTrace: stackTrace,
      );

      // Return the new error if it's a DioException, otherwise return original
      if (e is DioException) {
        return handler.next(e);
      }
      return handler.next(err);
    }
  }

  // Checks if the request shouldn't trigger refresh
  bool _isExcluded(String path) =>
      _excluded.any((p) => path == p || path.startsWith(p));

  // Queue the request until refresh is resolved
  Future<bool> _queueRequest(DioException err) {
    final completer = Completer<bool>();
    _queue.add(_QueuedRequest(completer));
    return completer.future;
  }

  // Main token refresh process (runs once)
  Future<bool> _refreshToken() async {
    try {
      final session = await _authRepository.getStoredSession();
      final refreshToken = session?.refreshToken;

      if (refreshToken == null) {
        _failAllRequests();
        _signOut('No refresh token available. Please sign in again.');
        return false;
      }

      // Check if refresh token is expired
      if (JwtUtils.isTokenExpired(refreshToken)) {
        _failAllRequests();
        _signOut('Your session has expired. Please sign in again.');
        return false;
      }

      final result = await _refreshTokenUseCase(
        RefreshTokenParams(refreshToken: refreshToken),
      );

      return await result.fold(
        (failure) async {
          _failAllRequests();
          _signOut('Failed to refresh session. Please sign in again.');
          return false;
        },
        (newSession) async {
          if (newSession.accessToken != null) {
            _apiClient.setAuthToken(newSession.accessToken);
          }

          // Store new session (includes new refresh token if rotated)
          if (newSession.refreshToken != null) {
            await _authRepository.storeSession(newSession);
          }

          _resolveAllRequests();
          return true;
        },
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Unexpected error during token refresh',
        error: e,
        stackTrace: stackTrace,
      );
      _failAllRequests();
      _signOut('An unexpected error occurred. Please sign in again.');
      return false;
    }
  }

  // Resolve all queued requests successfully
  void _resolveAllRequests() {
    for (final q in _queue) {
      q.completer.complete(true);
    }
    _queue.clear();
  }

  // Reject all queued requests due to refresh failure
  void _failAllRequests() {
    for (final q in _queue) {
      q.completer.complete(false);
    }
    _queue.clear();
  }

  // Retry the original request after refresh
  Future<Response> _retry(RequestOptions req) {
    final options = Options(
      method: req.method,
      headers: {
        ...req.headers,
        if (_apiClient.authToken != null)
          'Authorization': 'Bearer ${_apiClient.authToken}',
      },
      sendTimeout: req.sendTimeout,
      receiveTimeout: req.receiveTimeout,
      extra: req.extra,
      validateStatus: req.validateStatus,
    );

    return _apiClient.dio.request(
      req.path,
      data: req.data,
      queryParameters: req.queryParameters,
      options: options,
      cancelToken: null, // important: prevent auto-cancellation bugs
      onSendProgress: req.onSendProgress,
      onReceiveProgress: req.onReceiveProgress,
    );
  }

  // Sign out user if refresh fails, with reason for user notification
  void _signOut(String reason) {
    _apiClient.clearAuthToken();
    _authBloc.add(SessionExpiredEvent(reason));
  }
}

// Simple queued request holder
class _QueuedRequest {
  final Completer<bool> completer;

  _QueuedRequest(this.completer);
}
