import 'package:equatable/equatable.dart';

/// Session response entity containing authentication tokens
/// Note: User information is fetched separately via the current user endpoint
class SessionEnitity extends Equatable {
  final String? accessToken;
  final String? refreshToken;

  const SessionEnitity({
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

