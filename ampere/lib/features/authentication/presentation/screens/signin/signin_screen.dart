import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/features/authentication/presentation/logic/credentials_cubit.dart';
import 'package:ampere/features/authentication/presentation/logic/credentials_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CredentialsCubit(
        saveCredentialsUseCase: Injection.saveCredentialsUseCase,
        getCredentialsUseCase: Injection.getCredentialsUseCase,
        clearCredentialsUseCase: Injection.clearCredentialsUseCase,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Credentials Test'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Save Credentials Button
                BlocBuilder<CredentialsCubit, CredentialsState>(
                  builder: (context, state) {
                    final isLoading = state is CredentialsLoading;
                    return ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<CredentialsCubit>().saveCredentials(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    );
                              }
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Save Credentials'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12.0),

                // Get Credentials Button
                BlocBuilder<CredentialsCubit, CredentialsState>(
                  builder: (context, state) {
                    final isLoading = state is CredentialsLoading;
                    return OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<CredentialsCubit>().getCredentials();
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text('Get Credentials'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12.0),

                // Clear Credentials Button
                BlocBuilder<CredentialsCubit, CredentialsState>(
                  builder: (context, state) {
                    final isLoading = state is CredentialsLoading;
                    return OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<CredentialsCubit>().clearCredentials();
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                      label: const Text('Clear Credentials'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24.0),

                // State Display Section
                BlocBuilder<CredentialsCubit, CredentialsState>(
                  builder: (context, state) {
                    if (state is CredentialsInitial) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No operation performed yet',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    if (state is CredentialsLoading) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16.0),
                              Text('Loading...'),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is CredentialsSaved) {
                      return Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  'Credentials saved successfully!',
                                  style: TextStyle(color: Colors.green.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is CredentialsCleared) {
                      return Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.blue.shade700),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  'Credentials cleared successfully!',
                                  style: TextStyle(color: Colors.blue.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is CredentialsLoaded) {
                      if (state.credentials == null) {
                        return Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.orange.shade700),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    'No credentials found in storage',
                                    style: TextStyle(color: Colors.orange.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Auto-fill the form with loaded credentials
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _emailController.text = state.credentials!.email;
                        _passwordController.text = state.credentials!.password;
                      });

                      return Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.download_done, color: Colors.blue.shade700),
                                  const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  'Credentials loaded successfully!',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              _buildInfoRow('Email', state.credentials!.email),
                              const SizedBox(height: 8.0),
                              _buildInfoRow('Password', '••••••••'),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is CredentialsError) {
                      return Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red.shade700),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  state.message,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
