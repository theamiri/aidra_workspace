import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request.dart';

/// Sign-in request model extending the domain entity
/// Handles JSON serialization for API requests
class SignInRequestModel extends SignInRequest {
  const SignInRequestModel({
    required super.email,
    required super.password,
  });

  /// Create a SignInRequestModel from a JSON map
  factory SignInRequestModel.fromJson(Map<String, dynamic> json) {
    return SignInRequestModel(
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
  factory SignInRequestModel.fromEntity(SignInRequest entity) {
    return SignInRequestModel(
      email: entity.email,
      password: entity.password,
    );
  }
}

