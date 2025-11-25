import 'package:ampere/features/authentication/domain/entities/res_entites/session_response.dart';

/// Session response model extending the domain entity
/// Handles JSON serialization for API responses
/// Note: Sign-in response only contains tokens, user info is fetched separately
class SessionResponseModel extends SessionResponse {
  const SessionResponseModel({
    super.accessToken,
    super.refreshToken,
  });

  /// Create a SessionResponseModel from a JSON map
  factory SessionResponseModel.fromJson(Map<String, dynamic> json) {
    return SessionResponseModel(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        if (accessToken != null) 'accessToken': accessToken,
        if (refreshToken != null) 'refreshToken': refreshToken,
      };

  /// Create a SessionResponseModel from the domain entity
  factory SessionResponseModel.fromEntity(SessionResponse entity) {
    return SessionResponseModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
    );
  }
}

