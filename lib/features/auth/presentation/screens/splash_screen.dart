import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigate based on role
            if (state.user.isSiswa) {
              _navigateAfterDelay('/siswa-home');
            } else if (state.user.isAdminStan) {
              _navigateAfterDelay('/stan-orders');
            } else if (state.user.isSuperAdmin) {
              _navigateAfterDelay('/admin');
            }
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
