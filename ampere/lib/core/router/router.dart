import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/core/router/auth_listener.dart';
import 'package:ampere/core/router/routes.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

// Create a global AuthListener instance that listens to AuthBloc state changes
final _authListener = AuthListener(Injection.authBloc);

RouterConfig<Object> router() => GoRouter(
  navigatorKey: rootNavigatorKey,
  refreshListenable: _authListener,
  initialLocation: Routes.splash.route,
  redirect: (context, state) {
    print(_authListener.state);
    print(state.matchedLocation);
    // Use the listener's state which is reactive to AuthBloc changes
    final authState = _authListener.state;
    final currentLocation = state.matchedLocation;

    // Allow splash screen to handle initial navigation
    // Don't redirect from splash - let it check auth and navigate
    if (currentLocation == Routes.splash.route) {
      if (authState is Authenticated) {
        return Routes.dashboard.route;
      }
      if (authState is Unauthenticated) {
        return Routes.signIn.route;
      }
    }

    // // Protect dashboard route - require authentication
    // if (currentLocation == Routes.dashboard.route) {
    //   if (authState is! Authenticated) {
    //     return Routes.signIn.route;
    //   }
    //   return null;
    // }

    // // If authenticated and trying to access sign in, redirect to dashboard
    // if (currentLocation == Routes.signIn.route) {
    //   if (authState is Authenticated) {
    //     return Routes.dashboard.route;
    //   }
    //   return null;
    // }

    return null;
  },
  routes: <RouteBase>[
    Routes.splash.build,
    Routes.signIn.build,
    Routes.dashboard.build,
  ],
);
