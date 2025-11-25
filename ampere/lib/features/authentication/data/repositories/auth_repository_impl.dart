import 'package:ampere/features/authentication/data/data_sources/local_auth_data_source.dart';
import 'package:ampere/features/authentication/data/data_sources/remote_auth_data_source.dart';
import 'package:ampere/features/authentication/data/models/req_model/signin_request_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/session_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/user_model.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/session_entity.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
/// Combines remote and local data sources to provide authentication operations
class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource _remoteDataSource;
  final LocalAuthDataSource _localDataSource;

  AuthRepositoryImpl({
    required RemoteAuthDataSource remoteDataSource,
    required LocalAuthDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<SessionEnitity?> signIn(SignInRequestEntity signInRequest) async {
    try {
      final signInRequestModel = SignInRequestEntityModel.fromEntity(
        signInRequest,
      );
      final sessionResponseModel = await _remoteDataSource.signIn(
        signInRequestModel,
      );

      if (sessionResponseModel != null) {
        // Store session locally after successful sign-in
        await _localDataSource.storeSession(sessionResponseModel);
        // Store credentials for future use
        await _localDataSource.storeSignInCredentials(signInRequestModel);
        return sessionResponseModel;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();

      if (userModel != null) {
        // Store user locally after successful fetch
        await _localDataSource.storeUser(userModel);
        return userModel;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SessionEnitity?> refreshToken(String refreshToken) async {
    try {
      final sessionResponseModel = await _remoteDataSource.refreshToken(
        refreshToken,
      );

      if (sessionResponseModel != null) {
        // Store new session locally after successful refresh
        await _localDataSource.storeSession(sessionResponseModel);
        return sessionResponseModel;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (e) {
      // Log the error but don't throw - we'll still clear local data
      // This ensures logout works even if the server is unreachable
      // or the endpoint doesn't exist
      print('Remote sign out failed: $e');
    } finally {
      // Always clear all local data, regardless of remote call success
      await _localDataSource.clearAll();
    }
  }

  @override
  Future<void> storeSession(SessionEnitity session) async {
    try {
      final sessionModel = SessionEnitityModel.fromEntity(session);
      await _localDataSource.storeSession(sessionModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SessionEnitity?> getStoredSession() async {
    try {
      return await _localDataSource.getSession();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _localDataSource.clearSession();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> storeSignInCredentials(SignInRequestEntity credentials) async {
    try {
      final credentialsModel = SignInRequestEntityModel.fromEntity(credentials);
      await _localDataSource.storeSignInCredentials(credentialsModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SignInRequestEntity?> getStoredSignInCredentials() async {
    try {
      return await _localDataSource.getSignInCredentials();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearSignInCredentials() async {
    try {
      await _localDataSource.clearSignInCredentials();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> storeUser(UserEntity user) async {
    try {
      final userModel = UserEntityModel.fromEntity(user);
      await _localDataSource.storeUser(userModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getUser() async {
    try {
      return await _localDataSource.getUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _localDataSource.clearUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _localDataSource.clearAll();
    } catch (e) {
      rethrow;
    }
  }
}
