import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_bloc.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_event.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // Animation setup

    context.read<AuthBloc>().add(const AuthStatusChecked());
  }

  void _navigateAfterDelay(String route) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      context.go(route);
    });
  }

  void _checkStanProfile(Authenticated state) {
    if (state.user.isAdminStan) {
      // Check if stan profile exists
      context.read<StanProfileCompletionBloc>().add(
        CheckStanProfileRequested(userId: state.user.id),
      );
    } else {
      // For non-stan admins, navigate normally
      if (state.user.isSiswa) {
        _navigateAfterDelay('/siswa-home');
      } else if (state.user.isSuperAdmin) {
        _navigateAfterDelay('/admin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                _checkStanProfile(state);
              } else if (state is Unauthenticated) {
                _navigateAfterDelay('/select-role');
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
                _navigateAfterDelay('/select-role');
              }
            },
          ),
          BlocListener<StanProfileCompletionBloc, StanProfileCompletionState>(
            listener: (context, state) {
              if (state is StanProfileCompletionInitial || state is StanProfileCompletionLoading) {
                // Still checking, do nothing
              } else if (state is StanProfileSavedSuccessfully) {
                // Profile exists, navigate to admin dashboard
                _navigateAfterDelay('/admin');
              } else if (state is StanProfileCompletionError) {
                // Profile doesn't exist or error occurred, navigate to complete profile
                _navigateAfterDelay('/complete-stan-profile');
              }
            },
          ),
        ],
        child: Container(
          decoration: BoxDecoration(color: AppTheme.backgroundColor),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Image.asset('assets/logo/logo.png', width: 150, height: 150),
                const SizedBox(height: 20),
                // Loading indicator
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}