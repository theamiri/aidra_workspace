import 'package:ampere/features/authentication/domain/entities/res_entites/session_response.dart';
import 'package:ampere/features/authentication/data/models/user_model.dart';

/// Session response model extending the domain entity
/// Handles JSON serialization for API responses
class SessionResponseModel extends SessionResponse {
  const SessionResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.user,
  });

  /// Create a SessionResponseModel from a JSON map
  factory SessionResponseModel.fromJson(Map<String, dynamic> json) {
    return SessionResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user is UserModel 
            ? (user as UserModel).toJson() 
            : UserModel.fromEntity(user).toJson(),
      };

  /// Create a SessionResponseModel from the domain entity
  factory SessionResponseModel.fromEntity(SessionResponse entity) {
    return SessionResponseModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      user: UserModel.fromEntity(entity.user),
    );
  }
}

