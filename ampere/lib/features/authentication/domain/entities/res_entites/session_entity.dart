import 'package:equatable/equatable.dart';

/// Session entity containing authentication tokens
/// Note: User information is fetched separately via the current user endpoint
class SessionEntity extends Equatable {
  final String? accessToken;
  final String? refreshToken;

  const SessionEntity({
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

