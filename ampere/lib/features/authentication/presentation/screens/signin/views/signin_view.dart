import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_event.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';
import 'package:ampere/features/authentication/presentation/screens/signin/widgets/signin_button.dart';
import 'package:ampere/features/authentication/presentation/screens/signin/widgets/signin_email_field.dart';
import 'package:ampere/features/authentication/presentation/screens/signin/widgets/signin_error_display.dart';
import 'package:ampere/features/authentication/presentation/screens/signin/widgets/signin_password_field.dart';

/// Sign in view - main screen for user authentication
class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Sign in using AuthBloc
    final signInRequest = SignInRequestEntity(email: email, password: password);

    context.read<AuthBloc>().add(SignInEvent(signInRequest));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthenticationError,
      listener: (context, state) {
        if (state is AuthenticationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SignInEmailField(controller: _emailController),
                  const SizedBox(height: 16.0),
                  SignInPasswordField(
                    controller: _passwordController,
                    onSubmitted: _handleSignIn,
                  ),
                  const SizedBox(height: 24.0),
                  SignInButton(onPressed: _handleSignIn),
                  const SizedBox(height: 24.0),
                  const SignInErrorDisplay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
