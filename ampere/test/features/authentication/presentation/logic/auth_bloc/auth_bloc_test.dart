import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/session_entity.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ampere/features/authentication/domain/usecases/check_authentication_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/signin_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/signout_usecase.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_event.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockCheckAuthenticationUseCase extends Mock
    implements CheckAuthenticationUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc bloc;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockCheckAuthenticationUseCase mockCheckAuthenticationUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockCheckAuthenticationUseCase = MockCheckAuthenticationUseCase();
    mockAuthRepository = MockAuthRepository();

    bloc = AuthBloc(
      signInUseCase: mockSignInUseCase,
      signOutUseCase: mockSignOutUseCase,
      checkAuthenticationUseCase: mockCheckAuthenticationUseCase,
      authRepository: mockAuthRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const SignInRequestEntity(
        email: '',
        password: '',
      ),
    );
    registerFallbackValue(NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  group('AuthBloc', () {
    const tSignInRequest = SignInRequestEntity(
      email: 'test@example.com',
      password: 'password123',
    );

    const tSession = SessionEnitity(
      accessToken: 'accessToken',
      refreshToken: 'refreshToken',
    );

    const tUser = UserEntity(
      id: 1,
      email: 'test@example.com',
      firstname: 'Test',
      lastname: 'User',
    );

    test('initial state should be AuthInitial', () {
      expect(bloc.state, const AuthInitial());
    });

    test('isAuthenticated should return false when state is not Authenticated',
        () {
      expect(bloc.isAuthenticated, false);
    });

    test('currentUser should return null when state is not Authenticated', () {
      expect(bloc.currentUser, null);
    });

    blocTest<AuthBloc, AuthState>(
      'should emit [Authenticating, Authenticated] when SignInEvent is successful',
      build: () {
        when(() => mockSignInUseCase(any()))
            .thenAnswer((_) async => const Right(tSession));
        when(() => mockCheckAuthenticationUseCase(any()))
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInEvent(tSignInRequest)),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const Authenticating(),
        const Authenticated(tUser),
      ],
      verify: (_) {
        verify(() => mockSignInUseCase(tSignInRequest)).called(1);
        verify(() => mockCheckAuthenticationUseCase(NoParams())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [Authenticating, AuthenticationError] when SignInEvent fails',
      build: () {
        when(() => mockSignInUseCase(any())).thenAnswer(
          (_) async => Left(
            AuthenticationFailure(message: 'Invalid credentials'),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInEvent(tSignInRequest)),
      expect: () => [
        const Authenticating(),
        const AuthenticationError('Invalid credentials'),
      ],
      verify: (_) {
        verify(() => mockSignInUseCase(tSignInRequest)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [Authenticating, Unauthenticated] when SignOutEvent is successful',
      build: () {
        when(() => mockSignOutUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const Authenticating(),
        const Unauthenticated(),
      ],
      verify: (_) {
        verify(() => mockSignOutUseCase(NoParams())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [Authenticating, AuthenticationError] when SignOutEvent fails',
      build: () {
        when(() => mockSignOutUseCase(any())).thenAnswer(
          (_) async => Left(
            ServerFailure(message: 'Sign out failed'),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const Authenticating(),
        const AuthenticationError('Sign out failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [Authenticating, Authenticated] when CheckAuthenticationEvent is successful',
      build: () {
        when(() => mockCheckAuthenticationUseCase(any()))
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckAuthenticationEvent()),
      expect: () => [
        const Authenticating(),
        const Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [Authenticating, Unauthenticated] when CheckAuthenticationEvent returns null user',
      build: () {
        when(() => mockCheckAuthenticationUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckAuthenticationEvent()),
      expect: () => [
        const Authenticating(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [Authenticating, AuthenticationError] when CheckAuthenticationEvent fails',
      build: () {
        when(() => mockCheckAuthenticationUseCase(any())).thenAnswer(
          (_) async => Left(
            AuthenticationFailure(message: 'Authentication check failed'),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckAuthenticationEvent()),
      expect: () => [
        const Authenticating(),
        const AuthenticationError('Authentication check failed'),
      ],
    );
  });
}
