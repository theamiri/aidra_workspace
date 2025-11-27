import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_event.dart';
import 'package:dio/dio.dart';

/// Authentication interceptor for Dio
/// Automatically adds Bearer token to requests and handles 401 errors
/// Attempts to refresh token before clearing session
class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get stored session and add Bearer token to request
    final session = await Injection.authRepository.getStoredSession();
    if (session?.accessToken != null && session!.accessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // If we're already refreshing, queue this request
      if (_isRefreshing) {
        _pendingRequests.add(
          _PendingRequest(requestOptions: requestOptions, handler: handler),
        );
        return;
      }

      _isRefreshing = true;

      try {
        // Try to refresh the token
        final refreshed = await _tryRefreshToken();

        if (refreshed) {
          // Retry the original request with new token
          final session = await Injection.authRepository.getStoredSession();
          if (session?.accessToken != null &&
              session!.accessToken!.isNotEmpty) {
            requestOptions.headers['Authorization'] =
                'Bearer ${session.accessToken}';
          }

          // Retry the request
          final response = await Injection.apiClient.dio.fetch(requestOptions);
          handler.resolve(response);

          // Process pending requests
          _processPendingRequests();
        } else {
          // Refresh failed, clear session and sign out
          await _handleTokenExpiration();
          handler.next(err);
        }
      } catch (e) {
        // Refresh failed, clear session and sign out
        await _handleTokenExpiration();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  /// Try to refresh the access token using refresh token
  Future<bool> _tryRefreshToken() async {
    try {
      final session = await Injection.authRepository.getStoredSession();
      if (session?.refreshToken == null || session!.refreshToken!.isEmpty) {
        return false;
      }

      final refreshResult = await Injection.refreshTokenUseCase(
        RefreshTokenParams(refreshToken: session.refreshToken!),
      );

      return refreshResult.fold((failure) => false, (newSession) => true);
    } catch (e) {
      return false;
    }
  }

  /// Process pending requests after successful token refresh
  Future<void> _processPendingRequests() async {
    final session = await Injection.authRepository.getStoredSession();
    final newToken = session?.accessToken;

    for (final pending in _pendingRequests) {
      try {
        if (newToken != null) {
          pending.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        }
        final response = await Injection.apiClient.dio.fetch(
          pending.requestOptions,
        );
        pending.handler.resolve(response);
      } catch (e) {
        pending.handler.reject(
          DioException(requestOptions: pending.requestOptions, error: e),
        );
      }
    }

    _pendingRequests.clear();
  }

  /// Handle token expiration by clearing session and emitting sign out event
  Future<void> _handleTokenExpiration() async {
    try {
      await Injection.authRepository.clearSession();
      await Injection.authRepository.clearUser();
      // Emit sign out event to update auth state
      Injection.authBloc.add(const SignOutEvent());

      // Reject all pending requests
      for (final pending in _pendingRequests) {
        pending.handler.reject(
          DioException(
            requestOptions: pending.requestOptions,
            response: Response(
              requestOptions: pending.requestOptions,
              statusCode: 401,
            ),
          ),
        );
      }
      _pendingRequests.clear();
    } catch (e) {
      // Log error but don't throw
    }
  }
}

/// Helper class to store pending requests during token refresh
class _PendingRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _PendingRequest({required this.requestOptions, required this.handler});
}
