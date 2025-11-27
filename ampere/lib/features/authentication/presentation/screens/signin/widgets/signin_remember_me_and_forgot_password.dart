import 'package:flutter/material.dart';

/// Remember me checkbox and forgot password button
class SignInRememberMeAndForgotPassword extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onForgotPassword;

  const SignInRememberMeAndForgotPassword({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: (value) {
                onRememberMeChanged(value ?? false);
              },
            ),
            const Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: onForgotPassword,
          child: const Text('Forgot Password?'),
        ),
      ],
    );
  }
}

