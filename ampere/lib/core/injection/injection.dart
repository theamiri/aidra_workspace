import 'package:ampere/core/api/api_client.dart';
import 'package:ampere/core/api/logging_interceptor.dart';
import 'package:ampere/core/config/env_config.dart';
import 'package:ampere/core/storage/secure_storage.dart';
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
  
  getIt.registerFactory<LoggingInterceptor>(
    () => LoggingInterceptor(),
  );


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

}

/// Registers repositories
/// Repositories combine remote and local data sources
void _registerRepositories() {

}

/// Registers use cases
/// Use cases contain business logic and are used by the presentation layer
void _registerUseCases() {

}

Future<void> resetDependencies() async {
  await getIt.reset();
}

