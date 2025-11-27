import 'dart:async';
import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';

/// Callback function type for auth state changes
typedef AuthStateCallback = void Function(AuthState state);

/// Simple auth state listener utility
/// Can be used anywhere to listen to authentication state changes
///
/// Use this for:
/// - Non-UI code (services, routing, etc.)
/// - Places without BuildContext
/// - Listening to auth state changes
class AuthStateListener {
  /// Listen to auth state changes with a callback
  ///
  /// [callback] - Function to call when auth state changes
  ///
  /// Returns a StreamSubscription that can be cancelled
  static StreamSubscription<AuthState> listen(AuthStateCallback callback) {
    return Injection.authBloc.stream.listen(callback);
  }

  /// Get the AuthBloc instance
  static AuthBloc get bloc => Injection.authBloc;

  /// Get current auth state
  static AuthState get currentState => Injection.authBloc.state;

  /// Check if user is authenticated
  static bool get isAuthenticated => Injection.authBloc.isAuthenticated;

  /// Get current user if authenticated
  static UserEntity? get currentUser => Injection.authBloc.currentUser;
}
