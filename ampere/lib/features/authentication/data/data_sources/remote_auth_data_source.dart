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
  /// Returns [SessionEnitityModel?] containing access token and refresh token only
  /// Returns null if response data is empty
  /// Note: User information must be fetched separately using getCurrentUser()
  /// 
  /// Throws [AuthenticationException] if authentication fails
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<SessionEnitityModel?> signIn(SignInRequestEntityModel signInRequest) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: signInRequest.toJson(),
      );

      if (response.data == null) {
        return null;
      }

      final jsonData = response.data as Map<String, dynamic>;
      return SessionEnitityModel.fromJson(jsonData);
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

      final jsonData = response.data as Map<String, dynamic>;
      return UserEntityModel.fromJson(jsonData);
    } catch (e, stackTrace) {
      ErrorHandler.handleRemoteError(e, stackTrace, 'get current user');
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

