import 'package:equatable/equatable.dart';

/// Session response entity containing authentication tokens
/// Note: User information is fetched separately via the current user endpoint
class SessionResponse extends Equatable {
  final String? accessToken;
  final String? refreshToken;

  const SessionResponse({
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

