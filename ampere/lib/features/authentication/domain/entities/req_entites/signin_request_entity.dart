import 'package:equatable/equatable.dart';

/// Sign-in request entity containing user credentials
class SignInRequestEntity extends Equatable {
  final String email;
  final String password;

  const SignInRequestEntity({
    required this.email,
    required this.password,
  });

  /// Convert to JSON map for API requests
  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  @override
  List<Object?> get props => [email, password];
}

