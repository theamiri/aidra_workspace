import 'package:ampere/core/constants/app_strings.dart';
import 'package:ampere/core/router/router.dart';
import 'package:flutter/material.dart';

class AmpereApp extends StatelessWidget {
  const AmpereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router(),
      title: AppConstants.appName,
      debugShowCheckedModeBanner: !AppConstants.isProduction,
    );
  }
}
