import 'package:ampere/features/authentication/data/data_sources/local_auth_data_source.dart';
import 'package:ampere/features/authentication/data/data_sources/remote_auth_data_source.dart';
import 'package:ampere/features/authentication/data/models/session_model.dart';
import 'package:ampere/features/authentication/data/models/signin_request_model.dart';
import 'package:ampere/features/authentication/data/models/user_model.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/session_response.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
/// Combines remote and local data sources to provide authentication operations
class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource _remoteDataSource;
  final LocalAuthDataSource _localDataSource;

  AuthRepositoryImpl({
    required RemoteAuthDataSource remoteDataSource,
    required LocalAuthDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<SessionResponse?> signIn(SignInRequest signInRequest) async {
    try {
      final signInRequestModel = SignInRequestModel.fromEntity(signInRequest);
      final sessionResponseModel = await _remoteDataSource.signIn(signInRequestModel);
      
      if (sessionResponseModel != null) {
        // Store session locally after successful sign-in
        await _localDataSource.storeSessionResponse(sessionResponseModel);
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
  Future<User?> getCurrentUser() async {
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
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      // Clear all local data after sign out
      await _localDataSource.clearAll();
    } catch (e) {
      // Even if remote sign out fails, clear local data
      await _localDataSource.clearAll();
      rethrow;
    }
  }

  @override
  Future<void> storeSessionResponse(SessionResponse session) async {
    try {
      final sessionModel = SessionModel.fromEntity(session);
      await _localDataSource.storeSessionResponse(sessionModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SessionResponse?> getStoredSessionResponse() async {
    try {
      return await _localDataSource.getSessionResponse();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearSessionResponse() async {
    try {
      await _localDataSource.clearSessionResponse();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> storeSignInCredentials(SignInRequest credentials) async {
    try {
      final credentialsModel = SignInRequestModel.fromEntity(credentials);
      await _localDataSource.storeSignInCredentials(credentialsModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SignInRequest?> getStoredSignInCredentials() async {
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
  Future<void> storeUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _localDataSource.storeUser(userModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getStoredUser() async {
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

