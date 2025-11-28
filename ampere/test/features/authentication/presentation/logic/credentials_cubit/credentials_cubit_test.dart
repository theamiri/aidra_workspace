import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:ampere/features/authentication/domain/usecases/get_credentials_usecase.dart';
import 'package:ampere/features/authentication/presentation/logic/credentails_cubit/credentials_cubit.dart';
import 'package:ampere/features/authentication/presentation/logic/credentails_cubit/credentials_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCredentialsUseCase extends Mock implements GetCredentialsUseCase {}

void main() {
  late CredentialsCubit cubit;
  late MockGetCredentialsUseCase mockGetCredentialsUseCase;

  setUp(() {
    mockGetCredentialsUseCase = MockGetCredentialsUseCase();
    cubit = CredentialsCubit(
      getCredentialsUseCase: mockGetCredentialsUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  tearDown(() {
    cubit.close();
  });

  group('CredentialsCubit', () {
    const tCredentials = SignInRequestEntity(
      email: 'test@example.com',
      password: 'password123',
    );

    test('initial state should be CredentialsInitial', () {
      expect(cubit.state, const CredentialsInitial());
    });

    blocTest<CredentialsCubit, CredentialsState>(
      'should emit [CredentialsLoading, CredentialsLoaded] when getCredentials is successful',
      build: () {
        when(() => mockGetCredentialsUseCase(any()))
            .thenAnswer((_) async => const Right(tCredentials));
        return cubit;
      },
      act: (cubit) => cubit.getCredentials(),
      expect: () => [
        const CredentialsLoading(),
        const CredentialsLoaded(tCredentials),
      ],
      verify: (_) {
        verify(() => mockGetCredentialsUseCase(NoParams())).called(1);
      },
    );

    blocTest<CredentialsCubit, CredentialsState>(
      'should emit [CredentialsLoading, CredentialsLoaded] with null when no credentials found',
      build: () {
        when(() => mockGetCredentialsUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (cubit) => cubit.getCredentials(),
      expect: () => [
        const CredentialsLoading(),
        const CredentialsLoaded(null),
      ],
    );

    blocTest<CredentialsCubit, CredentialsState>(
      'should emit [CredentialsLoading, CredentialsError] when getCredentials fails',
      build: () {
        when(() => mockGetCredentialsUseCase(any())).thenAnswer(
          (_) async => Left(
            CacheFailure(message: 'Failed to load credentials'),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.getCredentials(),
      expect: () => [
        const CredentialsLoading(),
        const CredentialsError('Failed to load credentials'),
      ],
    );
  });
}
