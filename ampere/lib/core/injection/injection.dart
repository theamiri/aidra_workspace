import 'package:ampere/core/api/api_client.dart';
import 'package:ampere/core/api/logging_interceptor.dart';
import 'package:ampere/core/config/env_config.dart';
import 'package:ampere/core/storage/secure_storage.dart';
import 'package:ampere/features/authentication/data/data_sources/local_auth_data_source.dart';
import 'package:ampere/features/authentication/data/data_sources/remote_auth_data_source.dart';
import 'package:ampere/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ampere/features/authentication/domain/usecases/check_authentication_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/clear_credentials_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/clear_user_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/get_credentials_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/get_user_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/save_credentials_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/signin_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/signout_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/store_user_usecase.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Helper class for accessing registered dependencies
/// Provides type-safe access to commonly used services
class Injection {
  /// Gets the ApiClient instance
  static ApiClient get apiClient => getIt<ApiClient>();

  /// Gets a SecureStorage instance for a specific key
  /// [key] - The storage key identifier
  static SecureStorage secureStorage(String key) => SecureStorage(key: key);

  // Authentication Dependencies
  /// Gets the AuthRepository instance
  static AuthRepository get authRepository => getIt<AuthRepository>();

  /// Gets the SignInUseCase instance
  static SignInUseCase get signInUseCase => getIt<SignInUseCase>();

  /// Gets the SignOutUseCase instance
  static SignOutUseCase get signOutUseCase => getIt<SignOutUseCase>();

  /// Gets the CheckAuthenticationUseCase instance
  static CheckAuthenticationUseCase get checkAuthenticationUseCase =>
      getIt<CheckAuthenticationUseCase>();

  /// Gets the RefreshTokenUseCase instance
  static RefreshTokenUseCase get refreshTokenUseCase =>
      getIt<RefreshTokenUseCase>();

  /// Gets the SaveCredentialsUseCase instance
  static SaveCredentialsUseCase get saveCredentialsUseCase =>
      getIt<SaveCredentialsUseCase>();

  /// Gets the GetCredentialsUseCase instance
  static GetCredentialsUseCase get getCredentialsUseCase =>
      getIt<GetCredentialsUseCase>();

  /// Gets the ClearCredentialsUseCase instance
  static ClearCredentialsUseCase get clearCredentialsUseCase =>
      getIt<ClearCredentialsUseCase>();

  /// Gets the AuthBloc instance (global authentication management)
  static AuthBloc get authBloc => getIt<AuthBloc>();
}

Future<void> initializeDependencies() async {
  // Core Services
  _registerCoreServices();

  // API Services
  _registerApiServices();

  // Data Sources
  _registerDataSources();

  // Repositories
  _registerRepositories();

  // Use Cases
  _registerUseCases();

  // Presentation Components
  _registerPresentationComponents();
}

/// Registers core services
/// Add services that are used throughout the app here
void _registerCoreServices() {
  // Note: HiveClient and SecureStorage are created on-demand
  // as they require parameters (boxName/key) at creation time
  // Use Injection.secureStorage(key) to get SecureStorage instances
  // Create HiveClient instances directly: HiveClient<T>(boxName)
}

/// Registers API-related services
void _registerApiServices() {
  getIt.registerFactory<LoggingInterceptor>(() => LoggingInterceptor());

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: EnvConfig.apiBaseUrl,
      timeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}

/// Registers data sources
/// Data sources handle data fetching from remote APIs or local storage
void _registerDataSources() {
  // Authentication Data Sources
  getIt.registerLazySingleton<LocalAuthDataSource>(() => LocalAuthDataSource());

  getIt.registerLazySingleton<RemoteAuthDataSource>(
    () => RemoteAuthDataSource(getIt<ApiClient>()),
  );
}

/// Registers repositories
/// Repositories combine remote and local data sources
void _registerRepositories() {
  // Authentication Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<RemoteAuthDataSource>(),
      localDataSource: getIt<LocalAuthDataSource>(),
    ),
  );
}

/// Registers use cases
/// Use cases contain business logic and are used by the presentation layer
void _registerUseCases() {
  final authRepository = getIt<AuthRepository>();

  // Authentication Use Cases
  getIt.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(authRepository),
  );

  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(authRepository),
  );

  getIt.registerLazySingleton<CheckAuthenticationUseCase>(
    () => CheckAuthenticationUseCase(authRepository),
  );

  getIt.registerLazySingleton<RefreshTokenUseCase>(
    () => RefreshTokenUseCase(authRepository),
  );

  getIt.registerLazySingleton<SaveCredentialsUseCase>(
    () => SaveCredentialsUseCase(authRepository),
  );

  getIt.registerLazySingleton<GetCredentialsUseCase>(
    () => GetCredentialsUseCase(authRepository),
  );

  getIt.registerLazySingleton<ClearCredentialsUseCase>(
    () => ClearCredentialsUseCase(authRepository),
  );

  getIt.registerLazySingleton<StoreUserUseCase>(
    () => StoreUserUseCase(authRepository),
  );

  getIt.registerLazySingleton<GetUserUseCase>(
    () => GetUserUseCase(authRepository),
  );

  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(authRepository),
  );

  getIt.registerLazySingleton<ClearUserUseCase>(
    () => ClearUserUseCase(authRepository),
  );
}

/// Registers presentation layer components (Cubits, Blocs)
/// These are provided at the app level for global access
void _registerPresentationComponents() {
  // Global Authentication Bloc
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      signInUseCase: getIt<SignInUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      checkAuthenticationUseCase: getIt<CheckAuthenticationUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
