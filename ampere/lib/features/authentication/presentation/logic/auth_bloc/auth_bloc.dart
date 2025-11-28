import 'package:ampere/core/shared/use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ampere/features/authentication/domain/usecases/check_authentication_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/signin_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/signout_usecase.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_event.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';

/// Global authentication bloc
/// Manages authentication state and user information
/// Can be accessed anywhere in the app for authentication checks and user info
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final CheckAuthenticationUseCase _checkAuthenticationUseCase;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required CheckAuthenticationUseCase checkAuthenticationUseCase,
    required AuthRepository authRepository,
  }) : _signInUseCase = signInUseCase,
       _signOutUseCase = signOutUseCase,
       _checkAuthenticationUseCase = checkAuthenticationUseCase,
       super(const AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(const Authenticating());

    final result = await _signInUseCase(event.signInRequest);

    result.fold(
      (l) {
        emit(AuthenticationError(_getErrorMessage(l)));
      },
      (r) {
        add(CheckAuthenticationEvent());
      },
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const Authenticating());

    final result = await _signOutUseCase(NoParams());

    result.fold(
      (failure) {
        emit(AuthenticationError(_getErrorMessage(failure)));
      },
      (_) {
        emit(const Unauthenticated());
      },
    );
  }

  Future<void> _onCheckAuthentication(
    CheckAuthenticationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Authenticating());

    final result = await _checkAuthenticationUseCase(NoParams());
    result.fold(
      (l) {
        emit(AuthenticationError(_getErrorMessage(l)));
      },
      (r) {
        r == null ? emit(Unauthenticated()) : emit(Authenticated(r));
      },
    );
  }

  /// Get error message from failure
  String _getErrorMessage(Failure failure) {
    return failure.message;
  }

  /// Get the current authenticated user
  /// Returns null if not authenticated
  UserEntity? get currentUser {
    final state = this.state;
    if (state is Authenticated) {
      return state.user;
    }
    return null;
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated => state is Authenticated;
}
