import 'package:equatable/equatable.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to sign in a user
class SignInEvent extends AuthEvent {
  final SignInRequestEntity signInRequest;

  const SignInEvent(this.signInRequest);

  @override
  List<Object?> get props => [signInRequest];
}

/// Event to sign out a user
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Event to check authentication status
class CheckAuthenticationEvent extends AuthEvent {
  const CheckAuthenticationEvent();
}

