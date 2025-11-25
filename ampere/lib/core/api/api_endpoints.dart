

abstract class ApiEndpoints {
   // Base paths
  static const String authBasePath = '/api/auth';
  
  //authentication endpoints
  static const String login = '$authBasePath/authenticate';
  static const String logout = '$authBasePath/logout';
  static const String refreshToken = '$authBasePath/refresh-token';
  
  //user endpoints
  static const String currentUser = '$authBasePath/current-user';

 
}
