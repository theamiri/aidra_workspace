import 'package:flutter/material.dart';

/// Header widget for sign in screen
/// Displays logo, title, and subtitle
class SignInHeader extends StatelessWidget {
  const SignInHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60.0),
        // Logo/App Name
        const Icon(
          Icons.lock_outline,
          size: 80,
          color: Colors.deepPurple,
        ),
        const SizedBox(height: 24.0),
        // Title
        const Text(
          'Welcome Back',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        // Subtitle
        Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48.0),
      ],
    );
  }
}

