import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:ampere/features/authentication/domain/usecases/check_authentication_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/get_current_user_usecase.dart';
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
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required CheckAuthenticationUseCase checkAuthenticationUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthRepository authRepository,
  })  : _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _checkAuthenticationUseCase = checkAuthenticationUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
    on<SessionExpiredEvent>(_onSessionExpired);
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Authenticating());

    final result = await _signInUseCase(event.signInRequest);

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => throw Exception('Unexpected'));
      emit(AuthenticationError(_getErrorMessage(failure)));
      return;
    }

    final sessionResponse = result.fold((l) => throw Exception('Unexpected'), (r) => r);

    // Set access token in ApiClient before fetching user
    if (sessionResponse.accessToken != null) {
      Injection.apiClient.setAuthToken(sessionResponse.accessToken);
    }

    // After successful sign in, fetch current user from API
    final userResult = await _getCurrentUserUseCase(NoParams());

    if (emit.isDone) return;

    userResult.fold(
      (failure) {
        emit(AuthenticationError(_getErrorMessage(failure)));
      },
      (user) {
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Authenticating());

    final result = await _signOutUseCase(NoParams());

    // Clear auth token from ApiClient
    Injection.apiClient.clearAuthToken();

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

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => throw Exception('Unexpected'));
      
      // Clear auth token if authentication check fails
      Injection.apiClient.clearAuthToken();
      
      if (failure is AuthenticationFailure) {
        emit(const Unauthenticated());
      } else {
        emit(AuthenticationError(_getErrorMessage(failure)));
      }
      return;
    }

    final user = result.fold((l) => throw Exception('Unexpected'), (r) => r);

    // Set auth token from stored session if available
    final storedSession = await _authRepository.getStoredSession();
    if (storedSession?.accessToken != null) {
      Injection.apiClient.setAuthToken(storedSession!.accessToken);
    }

    if (emit.isDone) return;

    emit(Authenticated(user));
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

  Future<void> _onSessionExpired(
    SessionExpiredEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Show error message to user before signing out
    emit(AuthenticationError(event.reason));

    // Clear auth token from ApiClient
    Injection.apiClient.clearAuthToken();

    // Clear local session data
    try {
      await _authRepository.clearSession();
    } catch (e) {
      // Log but don't fail - we still want to sign out
    }

    // Transition to unauthenticated state after a brief delay
    // This allows the error message to be displayed
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (emit.isDone) return;
    emit(const Unauthenticated());
  }
}

