import 'dart:convert';
import 'package:ampere/features/authentication/domain/enums/role_enum.dart';

/// Utility class for JWT token operations
class JwtUtils {
  /// Extracts the role from a JWT token
  /// Handles roles as an array and takes only the first item
  /// 
  /// [token] - The JWT token string
  /// 
  /// Returns the Role enum value if found, null otherwise
  static Role? extractRole(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      final normalizedPayload = _normalizeBase64(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final payloadMap = jsonDecode(decodedString) as Map<String, dynamic>;

      // Try common role claim names
      final roleClaim = payloadMap['role'] ?? 
                       payloadMap['roles'] ?? 
                       payloadMap['authorities'];

      if (roleClaim == null) return null;

      // Handle roles as array - take first item
      String? roleString;
      if (roleClaim is List && roleClaim.isNotEmpty) {
        roleString = roleClaim.first.toString();
      } else if (roleClaim is String) {
        roleString = roleClaim;
      } else {
        return null;
      }

      return RoleParser.fromString(roleString);
    } catch (e) {
      return null;
    }
  }

  /// Normalizes base64url string by adding padding if needed
  static String _normalizeBase64(String base64) {
    final padding = 4 - (base64.length % 4);
    if (padding != 4) {
      return base64 + '=' * padding;
    }
    return base64;
  }
}

