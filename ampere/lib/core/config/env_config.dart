import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from .env files
class EnvConfig {
  /// Initialize environment variables from .env file
  /// Call this before runApp() in main.dart
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  /// Get environment type (development, production)
  static String get environment => dotenv.get('ENV');

  /// Get API base URL
  static String get apiBaseUrl => dotenv.get('API_BASE_URL');

  /// Get app name
  static String get appName => dotenv.get('APP_NAME');

  /// Check if debug banner should be shownenv
  static bool get showDebugBanner {
    final value = dotenv.get('SHOW_DEBUG_BANNER');
    return value.toLowerCase() == 'true';
  }

  /// Check if running in production
  static bool get isProduction =>
      environment.toLowerCase() == 'production' ||
      environment.toLowerCase() == 'prod';

  /// Check if running in development
  static bool get isDevelopment =>
      environment.toLowerCase() == 'development' ||
      environment.toLowerCase() == 'dev';

  /// Get environment display name
  static String get environmentDisplayName {
    if (isProduction) return '';
    return ' [${environment.toUpperCase()}]';
  }

  /// Get all environment variables (for debugging)
  static Map<String, String> get all => dotenv.env;
}
