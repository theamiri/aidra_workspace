import 'package:ampere/features/authentication/domain/enums/role_enum.dart';
import 'package:equatable/equatable.dart';

/// User entity representing a user in the system
class UserEntity extends Equatable {
  final int? id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final int? clientId;
  final int? siteId;
  final Role? role; // Role is extracted from JWT token, not from current user endpoint

  const UserEntity({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.phoneNumber,
    this.profilePictureUrl,
    this.clientId,
    this.siteId,
    this.role,
  });

  /// Get the full name of the user
  String? get fullName {
    if (firstname == null && lastname == null) return null;
    return '${firstname ?? ''} ${lastname ?? ''}'.trim();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstname,
        lastname,
        phoneNumber,
        profilePictureUrl,
        clientId,
        siteId,
        role,
      ];
}

