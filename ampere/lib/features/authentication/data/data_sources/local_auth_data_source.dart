import 'dart:convert';
import 'package:ampere/core/storage/secure_storage.dart';
import 'package:ampere/core/utils/error_handler.dart';
import 'package:ampere/features/authentication/data/models/req_model/signin_request_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/session_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/user_model.dart';

/// Local data source for authentication data
/// Handles storing and fetching session responses and sign-in credentials
class LocalAuthDataSource {
  // Storage keys
  static const String _sessionResponseKey = 'session_response';
  static const String _signInCredentialsKey = 'signin_credentials';
  static const String _userKey = 'user';

  // Secure storage instances
  final SecureStorage _sessionStorage;
  final SecureStorage _credentialsStorage;
  final SecureStorage _userStorage;

  LocalAuthDataSource()
      : _sessionStorage = SecureStorage(key: _sessionResponseKey),
        _credentialsStorage = SecureStorage(key: _signInCredentialsKey),
        _userStorage = SecureStorage(key: _userKey);

  /// Store session response (access token and refresh token)
  /// 
  /// [session] - The session response to store (contains only tokens)
  /// 
  /// Throws [CacheException] if storage fails
  Future<void> storeSessionResponse(SessionEnitityModel session) async {
    try {
      final jsonString = jsonEncode(session.toJson());
      await _sessionStorage.save(value: jsonString);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'store session response');
    }
  }

  /// Fetch stored session response
  /// 
  /// Returns [SessionEnitityModel] if found, null otherwise
  /// 
  /// Throws [CacheException] if retrieval fails
  Future<SessionEnitityModel?> getSessionResponse() async {
    try {
      final jsonString = await _sessionStorage.get();
      if (jsonString == null || jsonString.toString().isEmpty) {
        return null;
      }

      final jsonMap = jsonDecode(jsonString.toString()) as Map<String, dynamic>;
      return SessionEnitityModel.fromJson(jsonMap);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'get session response');
    }
  }

  /// Clear stored session response
  /// 
  /// Throws [CacheException] if deletion fails
  Future<void> clearSessionResponse() async {
    try {
      await _sessionStorage.delete();
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'clear session response');
    }
  }

  /// Store sign-in request credentials (email and password)
  /// 
  /// [credentials] - The sign-in request to store
  /// 
  /// Throws [CacheException] if storage fails
  Future<void> storeSignInCredentials(SignInRequestEntityModel credentials) async {
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
      final jsonString = jsonEncode(user.toJson());
      await _userStorage.save(value: jsonString);
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
      final jsonString = await _userStorage.get();
      if (jsonString == null || jsonString.toString().isEmpty) {
        return null;
      }

      final jsonMap = jsonDecode(jsonString.toString()) as Map<String, dynamic>;
      return UserEntityModel.fromJson(jsonMap);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'get user');
    }
  }

  /// Clear stored user information
  /// 
  /// Throws [CacheException] if deletion fails
  Future<void> clearUser() async {
    try {
      await _userStorage.delete();
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'clear user');
    }
  }

  /// Clear all authentication data (session, credentials, and user)
  /// 
  /// Throws [CacheException] if deletion fails
  Future<void> clearAll() async {
    try {
      await Future.wait([
        clearSessionResponse(),
        clearUser(),
      ]);
    } catch (e, stackTrace) {
      ErrorHandler.handleLocalError(e, stackTrace, 'clear all authentication data');
    }
  }
}

