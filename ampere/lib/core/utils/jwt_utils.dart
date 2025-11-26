import 'dart:convert';

/// Utility class for JWT token operations
class JwtUtils {
  /// Checks if a JWT token is expired
  /// 
  /// [token] - The JWT token to check
  /// 
  /// Returns true if the token is expired or invalid, false otherwise
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      
      // JWT should have 3 parts: header.payload.signature
      if (parts.length != 3) {
        return true;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      
      // Add padding if needed for base64Url decoding
      final normalized = base64Url.normalize(payload);
      final decoded = base64Url.decode(normalized);
      final payloadJson = json.decode(utf8.decode(decoded)) as Map<String, dynamic>;

      // Check expiration claim (exp)
      final exp = payloadJson['exp'];
      if (exp == null) {
        // No expiration claim means token doesn't expire (unusual but valid)
        return false;
      }

      // exp is in seconds since epoch, convert to DateTime
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
        (exp as int) * 1000,
      );

      // Check if token is expired (with 5 second buffer to account for clock skew)
      return expirationDate.isBefore(
        DateTime.now().subtract(const Duration(seconds: 5)),
      );
    } catch (e) {
      // If we can't parse the token, consider it expired/invalid
      return true;
    }
  }

  /// Gets the expiration date of a JWT token
  /// 
  /// [token] - The JWT token
  /// 
  /// Returns the expiration DateTime if found, null otherwise
  static DateTime? getTokenExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = base64Url.decode(normalized);
      final payloadJson = json.decode(utf8.decode(decoded)) as Map<String, dynamic>;

      final exp = payloadJson['exp'];
      if (exp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    } catch (e) {
      return null;
    }
  }
}

