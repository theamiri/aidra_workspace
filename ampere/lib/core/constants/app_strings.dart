import 'package:ampere/core/config/env_config.dart';

class AppConstants {
  /// Get app name
  static String get appName => EnvConfig.appName;
  
  /// Get API base URL
  static String get baseUrl => EnvConfig.apiBaseUrl;
  
  /// Check if running in production
  static bool get isProduction => EnvConfig.isProduction;
}