import 'package:ampere/features/authentication/domain/entities/res_entites/user.dart';
import 'package:ampere/features/authentication/domain/enums/role_enum.dart';

/// User model extending the domain entity
/// Handles JSON serialization for API responses
/// Note: Role is not returned from current user endpoint, it should be extracted from JWT token
class UserModel extends User {
  const UserModel({
    super.id,
    super.email,
    super.firstname,
    super.lastname,
    super.phoneNumber,
    super.profilePictureUrl,
    super.clientId,
    super.siteId,
    super.role,
  });

  /// Create a UserModel from a JSON map (current user endpoint response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      email: json['email'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      clientId: json['clientId'] as int?,
      siteId: json['siteId'] as int?,
      // Role is not in the response, it should be extracted from JWT token separately
      role: json['role'] != null 
          ? RoleParser.fromString(json['role'] as String?)
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (email != null) 'email': email,
        if (firstname != null) 'firstname': firstname,
        if (lastname != null) 'lastname': lastname,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        if (clientId != null) 'clientId': clientId,
        if (siteId != null) 'siteId': siteId,
        if (role != null) 'role': role!.value,
      };

  /// Create a UserModel from the domain entity
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      firstname: entity.firstname,
      lastname: entity.lastname,
      phoneNumber: entity.phoneNumber,
      profilePictureUrl: entity.profilePictureUrl,
      clientId: entity.clientId,
      siteId: entity.siteId,
      role: entity.role,
    );
  }
}

