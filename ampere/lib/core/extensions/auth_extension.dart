import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';

/// Extension on BuildContext to easily access AuthBloc and authentication information
extension AuthExtension on BuildContext {
  /// Get the AuthBloc instance
  AuthBloc get authBloc => read<AuthBloc>();

  /// Get the current authentication state
  AuthState get authState => read<AuthBloc>().state;

  /// Get the current authenticated user
  /// Returns null if not authenticated
  UserEntity? get currentUser => read<AuthBloc>().currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => read<AuthBloc>().isAuthenticated;

  /// Watch authentication state (for reactive UI updates)
  AuthState watchAuthState() => watch<AuthBloc>().state;

  /// Watch current user (for reactive UI updates)
  UserEntity? watchCurrentUser() {
    final state = watch<AuthBloc>().state;
    if (state is Authenticated) {
      return state.user;
    }
    return null;
  }
}

/// Global helper to access AuthBloc without BuildContext
/// Use this when you don't have access to BuildContext
class AuthHelper {
  /// Get the AuthBloc instance
  static AuthBloc get bloc => Injection.authBloc;

  /// Get the current authenticated user
  /// Returns null if not authenticated
  static UserEntity? get currentUser => Injection.authBloc.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => Injection.authBloc.isAuthenticated;

  /// Get the current authentication state
  static AuthState get state => Injection.authBloc.state;
}
