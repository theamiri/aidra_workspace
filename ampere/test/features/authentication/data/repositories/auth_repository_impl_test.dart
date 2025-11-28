import 'package:ampere/features/authentication/data/data_sources/local_auth_data_source.dart';
import 'package:ampere/features/authentication/data/data_sources/remote_auth_data_source.dart';
import 'package:ampere/features/authentication/data/models/req_model/signin_request_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/session_model.dart';
import 'package:ampere/features/authentication/data/models/res_model/user_model.dart';
import 'package:ampere/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteAuthDataSource extends Mock implements RemoteAuthDataSource {}

class MockLocalAuthDataSource extends Mock implements LocalAuthDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockRemoteAuthDataSource mockRemoteDataSource;
  late MockLocalAuthDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockRemoteAuthDataSource();
    mockLocalDataSource = MockLocalAuthDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const SignInRequestEntityModel(
        email: '',
        password: '',
      ),
    );
    registerFallbackValue(
      const SessionEnitityModel(
        accessToken: '',
        refreshToken: '',
      ),
    );
    registerFallbackValue(
      const UserEntityModel(
        id: 0,
        email: '',
      ),
    );
  });

  group('AuthRepositoryImpl', () {
    const tSignInRequest = SignInRequestEntity(
      email: 'test@example.com',
      password: 'password123',
    );

    const tSessionModel = SessionEnitityModel(
      accessToken: 'accessToken',
      refreshToken: 'refreshToken',
    );

    const tUserModel = UserEntityModel(
      id: 1,
      email: 'test@example.com',
      firstname: 'Test',
      lastname: 'User',
    );

    group('signIn', () {
      test('should store session and credentials when sign in is successful',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(any()))
            .thenAnswer((_) async => tSessionModel);
        when(() => mockLocalDataSource.storeSession(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.storeSignInCredentials(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.signIn(tSignInRequest);

        // Assert
        expect(result, tSessionModel);
        verify(() => mockRemoteDataSource.signIn(any())).called(1);
        verify(() => mockLocalDataSource.storeSession(tSessionModel)).called(1);
        verify(() => mockLocalDataSource.storeSignInCredentials(any()))
            .called(1);
      });

      test('should return null when remote data source returns null', () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(any()))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.signIn(tSignInRequest);

        // Assert
        expect(result, null);
        verify(() => mockRemoteDataSource.signIn(any())).called(1);
        verifyNever(() => mockLocalDataSource.storeSession(any()));
      });
    });

    group('getCurrentUser', () {
      test('should return user with role extracted from JWT token', () async {
        // Arrange
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => tUserModel);
        when(() => mockLocalDataSource.getSession())
            .thenAnswer((_) async => tSessionModel);
        when(() => mockLocalDataSource.storeUser(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
        verify(() => mockLocalDataSource.getSession()).called(1);
        verify(() => mockLocalDataSource.storeUser(any())).called(1);
      });

      test('should return null when remote data source returns null', () async {
        // Arrange
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, null);
        verifyNever(() => mockLocalDataSource.storeUser(any()));
      });
    });

    group('signOut', () {
      test('should call clearAll on local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.clearAll()).thenAnswer((_) async => {});

        // Act
        await repository.signOut();

        // Assert
        verify(() => mockLocalDataSource.clearAll()).called(1);
      });
    });

    group('getStoredSession', () {
      test('should return session from local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.getSession())
            .thenAnswer((_) async => tSessionModel);

        // Act
        final result = await repository.getStoredSession();

        // Assert
        expect(result, tSessionModel);
        verify(() => mockLocalDataSource.getSession()).called(1);
      });
    });

    group('clearSession', () {
      test('should call clearSession on local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.clearSession())
            .thenAnswer((_) async => {});

        // Act
        await repository.clearSession();

        // Assert
        verify(() => mockLocalDataSource.clearSession()).called(1);
      });
    });
  });
}
