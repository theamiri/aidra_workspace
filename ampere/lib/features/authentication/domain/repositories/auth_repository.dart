import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/session_entity.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';

/// Repository interface for authentication operations
/// Defines the contract for authentication data operations
abstract class AuthRepository {
  /// Sign in with email and password
  /// 
  /// [signInRequest] - The sign-in request containing email and password
  /// 
  /// Returns [SessionEntity?] containing access token and refresh token
  /// Returns null if sign-in fails or response is empty
  /// 
  /// Throws [AuthenticationException] if authentication fails
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<SessionEntity?> signIn(SignInRequestEntity signInRequest);

  /// Get current user information
  /// 
  /// Returns [UserEntity?] containing user details
  /// Returns null if user not found or response is empty
  /// 
  /// Throws [AuthenticationException] if not authenticated
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<UserEntity?> getCurrentUser();

  /// Refresh access token using refresh token
  /// 
  /// [refreshToken] - The refresh token to use for getting new tokens
  /// 
  /// Returns [SessionEntity?] containing new access token and refresh token
  /// Returns null if refresh fails or response is empty
  /// 
  /// Throws [AuthenticationException] if refresh token is invalid or expired
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<SessionEntity?> refreshToken(String refreshToken);

  /// Sign out the current user
  /// 
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network connection fails
  Future<void> signOut();

  /// Store session locally
  /// 
  /// [session] - The session to store
  /// 
  /// Throws [CacheException] if storage fails
  Future<void> storeSession(SessionEntity session);

  /// Get stored session
  /// 
  /// Returns [SessionEntity?] if found, null otherwise
  /// 
  /// Throws [CacheException] if retrieval fails
  Future<SessionEntity?> getStoredSession();

  /// Clear stored session
  /// 
  /// Throws [CacheException] if deletion fails
  Future<void> clearSession();

  /// Store sign-in credentials locally
  /// 
  /// [credentials] - The sign-in request to store
  /// 
  /// Throws [CacheException] if storage fails
  Future<void> storeSignInCredentials(SignInRequestEntity credentials);

  /// Get stored sign-in credentials
  /// 
  /// Returns [SignInRequestEntity?] if found, null otherwise
  /// 
  /// Throws [CacheException] if retrieval fails
  Future<SignInRequestEntity?> getStoredSignInCredentials();

  /// Clear stored sign-in credentials
  /// 
  /// Throws [CacheException] if deletion fails
  Future<void> clearSignInCredentials();

  /// Store user information locally
  /// 
  /// [user] - The user to store
  /// 
  /// Throws [CacheException] if storage fails
  Future<void> storeUser(UserEntity user);

  /// Get stored user information
  /// 
  /// Returns [UserEntity?] if found, null otherwise
  /// 
  /// Throws [CacheException] if retrieval fails
  Future<UserEntity?> getUser();

  /// Clear stored user information
  /// 
  /// Throws [CacheException] if deletion fails
  Future<void> clearUser();

  /// Clear all authentication data (session, credentials, and user)
  /// 
  /// Throws [CacheException] if deletion fails
  Future<void> clearAll();
}

