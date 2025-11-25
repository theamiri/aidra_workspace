import 'package:ampere/features/authentication/domain/enums/role_enum.dart';
import 'package:equatable/equatable.dart';

/// User entity representing a user in the system
class User extends Equatable {
  final String email;
  final String firstname;
  final String lastname;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final Role role;

  const User({
    required this.email,
    required this.firstname,
    required this.lastname,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
  });

  /// Get the full name of the user
  String get fullName => '$firstname $lastname';

  @override
  List<Object?> get props => [
        email,
        firstname,
        lastname,
        phoneNumber,
        profilePictureUrl,
        role,
      ];
}

