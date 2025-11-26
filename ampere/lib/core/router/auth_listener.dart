import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';

/// ChangeNotifier that listens to AuthBloc state changes
/// Used to make GoRouter redirect reactive to authentication state changes
class AuthListener extends ChangeNotifier {
  final AuthBloc _authBloc;
  StreamSubscription<AuthState>? _subscription;

  AuthListener(this._authBloc) {
    // Listen to AuthBloc state changes
    _subscription = _authBloc.stream.listen((state) {
      // Notify listeners (GoRouter) when auth state changes
      notifyListeners();
    });
  }

  /// Get the current authentication state
  AuthState get state => _authBloc.state;

  /// Check if user is authenticated
  bool get isAuthenticated => _authBloc.isAuthenticated;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

