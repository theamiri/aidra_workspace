import 'package:ampere/features/authentication/presentation/screens/signin/signin_screen.dart';
import 'package:ampere/features/splash/presentation/splash_screen.dart';
import 'package:go_router/go_router.dart';

enum Routes {
  splash,
  signIn,
}

extension RoutesExtension on Routes {
  String get route {
    switch (this) {
      case Routes.splash:
        return '/splash';
      case Routes.signIn:
        return '/singin';
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
      }
    }
  }