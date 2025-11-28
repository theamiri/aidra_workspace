import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/session_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ampere/features/authentication/domain/usecases/signin_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  group('SignInUseCase', () {
    const tSignInRequest = SignInRequestEntity(
      email: 'test@example.com',
      password: 'password123',
    );

    const tSession = SessionEnitity(
      accessToken: 'accessToken',
      refreshToken: 'refreshToken',
    );

    test('should return SessionEntity when sign in is successful', () async {
      // Arrange
      when(() => mockRepository.signIn(tSignInRequest))
          .thenAnswer((_) async => tSession);

      // Act
      final result = await useCase(tSignInRequest);

      // Assert
      expect(result, const Right(tSession));
      verify(() => mockRepository.signIn(tSignInRequest)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository returns null', () async {
      // Arrange
      when(() => mockRepository.signIn(tSignInRequest))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase(tSignInRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Sign in failed: Empty response from server');
        },
        (_) => fail('Should return Left'),
      );
      verify(() => mockRepository.signIn(tSignInRequest)).called(1);
    });

    test('should return Failure when repository throws AppException', () async {
      // Arrange
      const exception = AuthenticationException(message: 'Invalid credentials');
      when(() => mockRepository.signIn(tSignInRequest)).thenThrow(exception);

      // Act
      final result = await useCase(tSignInRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthenticationFailure>());
          expect(failure.message, 'Invalid credentials');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return UnexpectedFailure when unexpected error occurs',
        () async {
      // Arrange
      when(() => mockRepository.signIn(tSignInRequest))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(tSignInRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, 'Unexpected error during sign in');
        },
        (_) => fail('Should return Left'),
      );
    });
  });
}
