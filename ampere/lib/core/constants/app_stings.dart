import 'package:ampere/config/env_config.dart';

class AppConstants {
  /// Get app name
    static String get appName => EnvConfig.appName;
  /// Get app version
  static  String get appVersion => EnvConfig.appVersion;
}