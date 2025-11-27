import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ampere/core/router/routes.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_bloc.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_event.dart';
import 'package:ampere/features/authentication/presentation/logic/auth_bloc/auth_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Dispatch sign out event
      context.read<AuthBloc>().add(const SignOutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigate to sign in screen after successful logout
        if (state is Unauthenticated) {
          context.go(Routes.signIn.route);
        } else if (state is AuthenticationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is Authenticating;
                return IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.logout),
                  onPressed: isLoading ? null : () => _handleLogout(context),
                  tooltip: 'Logout',
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              final user = state.user;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // User profile picture or placeholder
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: user.profilePictureUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user.profilePictureUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.deepPurple.shade300,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.deepPurple.shade300,
                            ),
                    ),
                    const SizedBox(height: 24),
                    // User name
                    if (user.fullName != null && user.fullName!.isNotEmpty)
                      Text(
                        user.fullName!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                    else if (user.email != null)
                      Text(
                        user.email!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    const SizedBox(height: 8),
                    // User email
                    if (user.email != null)
                      Text(
                        user.email!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 32),
                    // User email
                    Text(
                      user.role?.name ?? 'no role found',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Logout button
                    ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Loading or error state
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
