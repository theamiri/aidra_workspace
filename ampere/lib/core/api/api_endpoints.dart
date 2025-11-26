/// API endpoints for the application
/// Centralized location for all API route definitions
abstract class ApiEndpoints {
  // Base paths
  static const String authBasePath = '/api/auth';

  // Authentication endpoints
  static const String login = '$authBasePath/authenticate';
  static const String logout = '$authBasePath/logout';
  static const String refreshToken = '$authBasePath/refresh-token';

  // User endpoints
  static const String currentUser = '$authBasePath/current-user';
}
