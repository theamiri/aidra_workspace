import 'package:ampere/core/listeners/auth_state_listener.dart';
import 'package:ampere/core/router/routes.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

RouterConfig<Object> router() {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash.route,
    redirect: (context, state) {
      final authState = AuthStateListener.currentState;
      final currentLocation = state.matchedLocation;

      // Allow splash screen to handle initial navigation
      if (currentLocation == Routes.splash.route) {
        if (authState is Authenticated) {
          return Routes.dashboard.route;
        } else {
          return Routes.signIn.route;
        }
      }

      return null;
    },
    routes: <RouteBase>[
      Routes.splash.build,
      Routes.signIn.build,
      Routes.dashboard.build,
    ],
  );

  // Listen to auth state changes and refresh router
  AuthStateListener.listen((authState) {
    router.refresh();
  });

  return router;
}
