import 'package:equatable/equatable.dart';
import 'package:ampere/features/authentication/domain/entities/user.dart';

/// Session response entity containing authentication tokens and user information
class SessionResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final User user;

  const SessionResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}

