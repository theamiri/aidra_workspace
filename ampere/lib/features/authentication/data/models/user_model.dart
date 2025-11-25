import 'package:ampere/features/authentication/domain/entities/res_entites/user.dart';
 import 'package:ampere/features/authentication/domain/enums/role_enum.dart';

/// User model extending the domain entity
/// Handles JSON serialization for API responses
class UserModel extends User {
  const UserModel({
    required super.email,
    required super.firstname,
    required super.lastname,
    super.phoneNumber,
    super.profilePictureUrl,
    required super.role,
  });

  /// Create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      role: RoleParser.fromString(json['role'] as String?) ?? Role.user,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'email': email,
        'firstname': firstname,
        'lastname': lastname,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        'role': role.value,
      };

  /// Create a UserModel from the domain entity
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      email: entity.email,
      firstname: entity.firstname,
      lastname: entity.lastname,
      phoneNumber: entity.phoneNumber,
      profilePictureUrl: entity.profilePictureUrl,
      role: entity.role,
    );
  }
}

