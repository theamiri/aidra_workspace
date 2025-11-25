import 'package:ampere/features/authentication/presentation/screens/signin/signin_screen.dart';
import 'package:ampere/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ampere/features/splash/presentation/splash_screen.dart';
import 'package:go_router/go_router.dart';

enum Routes {
  splash,
  signIn,
  dashboard,
}

extension RoutesExtension on Routes {
  String get route {
    switch (this) {
      case Routes.splash:
        return '/splash';
      case Routes.signIn:
        return '/signin';
      case Routes.dashboard:
        return '/dashboard';
    }
  }
}

extension BuildRoutes on Routes {
  GoRoute get build {
    switch (this) {
      case Routes.splash:
        return GoRoute(
          path: route,
          builder: (context, state) => const SplashScreen(),
        );
      case Routes.signIn:
        return GoRoute(
          path: route,
          builder: (context, state) => const SignInScreen(),
        );
      case Routes.dashboard:
        return GoRoute(
          path: route,
          builder: (context, state) => const DashboardScreen(),
        );
    }
  }
}