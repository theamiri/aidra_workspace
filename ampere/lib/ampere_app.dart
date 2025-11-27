import 'package:ampere/core/constants/app_strings.dart';
import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/core/router/router.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmpereApp extends StatefulWidget {
  const AmpereApp({super.key});

  @override
  State<AmpereApp> createState() => _AmpereAppState();
}

class _AmpereAppState extends State<AmpereApp> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on app startup
    // Use Injection.authBloc instead of context.authBloc since BlocProvider
    // is created in build method, not available in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Injection.authBloc.add(const CheckAuthenticationEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: Injection.authBloc,
      child: MaterialApp.router(
        routerConfig: router(),
        title: AppConstants.appName,
        debugShowCheckedModeBanner: !AppConstants.isProduction,
      ),
    );
  }
}
