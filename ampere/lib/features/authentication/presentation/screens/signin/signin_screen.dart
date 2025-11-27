import 'package:flutter/material.dart';
import 'package:ampere/features/authentication/presentation/screens/signin/views/signin_view.dart';

/// Sign in screen - entry point for sign in feature
/// This is a thin wrapper that provides the screen for routing
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignInView();
  }
}
