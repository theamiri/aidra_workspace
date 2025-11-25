import 'package:ampere/core/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

RouterConfig<Object> router() => GoRouter(
  navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash.route,
    routes: <RouteBase>[
      Routes.splash.build,
      Routes.signIn.build,
    ],
    
);