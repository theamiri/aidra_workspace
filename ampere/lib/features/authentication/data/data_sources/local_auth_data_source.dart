import 'dart:convert';
import 'package:ampere/core/storage/hive_client.dart';
import 'package:ampere/core/storage/secure_storage.dart';
import 'package:ampere/core/utils/error_handler.dart';
import 'package:ampere/features/authentication/data/models/req_model/signin_request_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/session_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/user_model.dart';

/// Local data source for authentication data
/// Handles storing and fetching session and sign-in credentials
class LocalAuthDataSource {
  // Storage keys
  static const String _sessionResponseKey = 'session_response';
  static const String _signInCredentialsKey = 'signin_credentials';
  static const String _userBoxName = 'user_box';
  static const String _userKey = 'user';

  // Secure storage instances (for sensitive data)
  final SecureStorage _sessionStorage;
  final SecureStorage _credentialsStorage;

  // Hive client for non-sensitive user data
  final HiveClient<Map<String, dynamic>> _userHiveClient;

  LocalAuthDataSource()
    : _sessionStorage = SecureStorage(key: _sessionResponseKey),
      _credentialsStorage = SecureStorage(key: _signInCredentialsKey),
      _userHiveClient = HiveClient<Map<String, dynamic>>(_userBoxName);

  /// Store session (access token and refresh token)
  ///
  /// [session] - The session to store (contains only tokens)
  ///
  /// Throws [CacheException] if storage fails
  Future<void> storeSession(SessionEntityModel session) async {
    try {
      final jsonString = jsonEncode(session.toJson());
      await _sessionStorage.save(value: jsonString);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'store session');
    }
  }

  /// Fetch stored session
  ///
  /// Returns [SessionEntityModel] if found, null otherwise
  ///
  /// Throws [CacheException] if retrieval fails
  Future<SessionEntityModel?> getSession() async {
    try {
      final jsonString = await _sessionStorage.get();
      if (jsonString == null || jsonString.toString().isEmpty) {
        return null;
      }

      final jsonMap = jsonDecode(jsonString.toString()) as Map<String, dynamic>;
      return SessionEntityModel.fromJson(jsonMap);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'get session');
    }
  }

  /// Clear stored session
  ///
  /// Throws [CacheException] if deletion fails
  Future<void> clearSession() async {
    try {
      await _sessionStorage.delete();
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'clear session');
    }
  }

  /// Store sign-in request credentials (email and password)
  ///
  /// [credentials] - The sign-in request to store
  ///
  /// Throws [CacheException] if storage fails
  Future<void> storeSignInCredentials(
    SignInRequestEntityModel credentials,
  ) async {
    try {
      final jsonString = jsonEncode(credentials.toJson());
      await _credentialsStorage.save(value: jsonString);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'store sign-in credentials');
    }
  }

  /// Fetch stored sign-in request credentials
  ///
  /// Returns [SignInRequestEntityModel] if found, null otherwise
  ///
  /// Throws [CacheException] if retrieval fails
  Future<SignInRequestEntityModel?> getSignInCredentials() async {
    try {
      final jsonString = await _credentialsStorage.get();
      if (jsonString == null || jsonString.toString().isEmpty) {
        return null;
      }

      final jsonMap = jsonDecode(jsonString.toString()) as Map<String, dynamic>;
      return SignInRequestEntityModel.fromJson(jsonMap);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'get sign-in credentials');
    }
  }

  /// Clear stored sign-in credentials
  ///
  /// Throws [CacheException] if deletion fails
  Future<void> clearSignInCredentials() async {
    try {
      await _credentialsStorage.delete();
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'clear sign-in credentials');
    }
  }

  /// Store user information
  ///
  /// [user] - The user model to store
  ///
  /// Throws [CacheException] if storage fails
  Future<void> storeUser(UserEntityModel user) async {
    try {
      await _userHiveClient.init();
      final userJson = user.toJson();
      await _userHiveClient.put(_userKey, userJson);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'store user');
    }
  }

  /// Fetch stored user information
  ///
  /// Returns [UserEntityModel] if found, null otherwise
  ///
  /// Throws [CacheException] if retrieval fails
  Future<UserEntityModel?> getUser() async {
    try {
      await _userHiveClient.init();
      final userJson = await _userHiveClient.get(_userKey);
      if (userJson == null) {
        return null;
      }

      return UserEntityModel.fromJson(userJson);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'get user');
    }
  }

  /// Clear stored user information
  ///
  /// Throws [CacheException] if deletion fails
  Future<void> clearUser() async {
    try {
      await _userHiveClient.init();
      await _userHiveClient.delete(_userKey);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'clear user');
    }
  }

  /// Clear all authentication data (session, credentials, and user)
  ///
  /// Throws [CacheException] if deletion fails
  Future<void> clearAll() async {
    try {
      await Future.wait([clearSession(), clearUser()]);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(
        e,
        stackTrace,
        'clear all authentication data',
      );
    }
  }
}
