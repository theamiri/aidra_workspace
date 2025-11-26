import 'package:ampere/core/api/api_client.dart';
import 'package:ampere/core/api/api_endpoints.dart';
import 'package:ampere/core/utils/error_handler.dart';
import 'package:ampere/features/authentication/data/models/req_model/signin_request_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/session_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/user_model.dart';

/// Remote data source for authentication
/// Handles API calls for sign in and sign out
class RemoteAuthDataSource {
  final ApiClient _apiClient;

  RemoteAuthDataSource(this._apiClient);

  /// Sign in with email and password
  /// 
  /// [signInRequest] - The sign-in request containing email and password
  /// 
  /// Returns [SessionEntityModel?] containing access token and refresh token only
  /// Returns null if response data is empty
  /// Note: User information must be fetched separately using getCurrentUser()
  /// 
  /// Throws [AuthenticationException] if authentication fails
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<SessionEntityModel?> signIn(SignInRequestEntityModel signInRequest) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: signInRequest.toJson(),
      );

      if (response.data == null) {
        return null;
      }

      // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
      final dynamic data = response.data;
      if (data is! Map) {
        throw FormatException('Expected Map but got ${data.runtimeType}');
      }
      final jsonData = _convertToMapStringDynamic(data);
      return SessionEntityModel.fromJson(jsonData);
    } catch (e, stackTrace) {
      ErrorHandler.handleRemoteError(e, stackTrace, 'sign in');
    }
  }

  /// Get current user information
  /// 
  /// Returns [UserEntityModel?] containing user details
  /// Returns null if response data is empty
  /// 
  /// Throws [AuthenticationException] if not authenticated
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<UserEntityModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.currentUser,
      );

      if (response.data == null) {
        return null;
      }

      // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
      // Handle both Map<dynamic, dynamic> and Map<String, dynamic> cases
      final dynamic data = response.data;
      if (data is! Map) {
        throw FormatException('Expected Map but got ${data.runtimeType}');
      }
      
      // Recursively convert nested maps to ensure all are Map<String, dynamic>
      final jsonData = _convertToMapStringDynamic(data);
      return UserEntityModel.fromJson(jsonData);
    } catch (e, stackTrace) {
      ErrorHandler.handleRemoteError(e, stackTrace, 'get current user');
    }
  }

  /// Recursively converts Map<dynamic, dynamic> to Map<String, dynamic>
  /// Also handles nested maps and lists
  Map<String, dynamic> _convertToMapStringDynamic(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        final String stringKey = key.toString();
        final dynamic convertedValue = value is Map
            ? _convertToMapStringDynamic(value)
            : value is List
                ? value.map((item) => item is Map
                    ? _convertToMapStringDynamic(item)
                    : item).toList()
                : value;
        return MapEntry(stringKey, convertedValue);
      });
    }
    throw FormatException('Expected Map but got ${data.runtimeType}');
  }

  /// Refresh access token using refresh token
  /// 
  /// [refreshToken] - The refresh token to use for getting new tokens
  /// 
  /// Returns [SessionEntityModel?] containing new access token and refresh token
  /// Returns null if response data is empty
  /// 
  /// Throws [AuthenticationException] if refresh token is invalid or expired
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<SessionEntityModel?> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.data == null) {
        return null;
      }

      // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
      final dynamic data = response.data;
      if (data is! Map) {
        throw FormatException('Expected Map but got ${data.runtimeType}');
      }
      final jsonData = _convertToMapStringDynamic(data);
      return SessionEntityModel.fromJson(jsonData);
    } catch (e, stackTrace) {
      ErrorHandler.handleRemoteError(e, stackTrace, 'refresh token');
    }
  }

  /// Sign out the current user
  /// 
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<void> signOut() async {
    try {
      await _apiClient.post(
        ApiEndpoints.logout,
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleRemoteError(e, stackTrace, 'sign out');
    }
  }
}

