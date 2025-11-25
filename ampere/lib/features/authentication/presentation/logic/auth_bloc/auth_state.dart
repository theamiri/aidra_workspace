import 'package:equatable/equatable.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';

/// Base class for authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - authentication status not yet checked
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Authenticating state - authentication operation is in progress
class Authenticating extends AuthState {
  const Authenticating();
}

/// Authenticated state - user is authenticated
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state - user is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication error state - authentication operation failed
class AuthenticationError extends AuthState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object?> get props => [message];
}

