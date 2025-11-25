import 'package:ampere/features/authentication/domain/entities/res_entites/session_entity.dart';

/// Session model extending the domain entity
/// Handles JSON serialization for API responses
/// Note: Sign-in response only contains tokens, user info is fetched separately
class SessionEnitityModel extends SessionEnitity {
  const SessionEnitityModel({
    super.accessToken,
    super.refreshToken,
  });

  /// Create a SessionModel from a JSON map
  factory SessionEnitityModel.fromJson(Map<String, dynamic> json) {
    return SessionEnitityModel(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        if (accessToken != null) 'accessToken': accessToken,
        if (refreshToken != null) 'refreshToken': refreshToken,
      };

  /// Create a SessionModel from the domain entity
  factory SessionEnitityModel.fromEntity(SessionEnitity entity) {
    return SessionEnitityModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
    );
  }
}

