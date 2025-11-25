import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/core/router/routes.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

RouterConfig<Object> router() => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.splash.route,
  redirect: (context, state) {
    final authState = Injection.authBloc.state;
    final currentLocation = state.matchedLocation;

    // Allow splash screen to handle initial navigation
    // Don't redirect from splash - let it check auth and navigate
    if (currentLocation == Routes.splash.route) {
      return null;
    }

    // Protect dashboard route - require authentication
    if (currentLocation == Routes.dashboard.route) {
      if (authState is! Authenticated) {
        return Routes.signIn.route;
      }
      return null;
    }

    // If authenticated and trying to access sign in, redirect to dashboard
    if (currentLocation == Routes.signIn.route) {
      if (authState is Authenticated) {
        return Routes.dashboard.route;
      }
      return null;
    }

    return null;
  },
  routes: <RouteBase>[
    Routes.splash.build,
    Routes.signIn.build,
    Routes.dashboard.build,
  ],
);
