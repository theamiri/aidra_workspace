import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';

/// Sign-in request model extending the domain entity
/// Handles JSON serialization for API requests
class SignInRequestEntityModel extends SignInRequestEntity {
  const SignInRequestEntityModel({
    required super.email,
    required super.password,
  });

  /// Create a SignInRequestModel from a JSON map
  factory SignInRequestEntityModel.fromJson(Map<String, dynamic> json) {
    return SignInRequestEntityModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  /// Convert to JSON map for API requests
  @override
  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  /// Create a SignInRequestModel from the domain entity
  factory SignInRequestEntityModel.fromEntity(SignInRequestEntity entity) {
    return SignInRequestEntityModel(
      email: entity.email,
      password: entity.password,
    );
  }
}

