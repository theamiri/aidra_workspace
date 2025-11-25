import 'package:equatable/equatable.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';

/// Base class for credentials states
abstract class CredentialsState extends Equatable {
  const CredentialsState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no credential operation has been performed
class CredentialsInitial extends CredentialsState {
  const CredentialsInitial();
}

/// Loading state - credential operation is in progress
class CredentialsLoading extends CredentialsState {
  const CredentialsLoading();
}

/// Credentials loaded state - credentials have been retrieved
class CredentialsLoaded extends CredentialsState {
  final SignInRequestEntity? credentials;

  const CredentialsLoaded(this.credentials);

  @override
  List<Object?> get props => [credentials];
}

/// Credentials saved state - credentials have been saved successfully
class CredentialsSaved extends CredentialsState {
  const CredentialsSaved();
}

/// Credentials cleared state - credentials have been cleared successfully
class CredentialsCleared extends CredentialsState {
  const CredentialsCleared();
}

/// Error state - credential operation failed
class CredentialsError extends CredentialsState {
  final String message;

  const CredentialsError(this.message);

  @override
  List<Object?> get props => [message];
}

