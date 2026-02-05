import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/utils/constants.dart';
import 'package:kantin_app/core/widgets/custom_textfield.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_bloc.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_event.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_state.dart';

import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final String? selectedRole;

  const LoginScreen({super.key, this.selectedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isGoogleSignIn = false; // Track if the current action is Google sign-in

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else if (state is Authenticated) {
                // Validasi role di UI layer
                if (widget.selectedRole != null &&
                    widget.selectedRole != state.user.role) {
                  // Role tidak cocok, kembali ke role selector
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Peran yang dipilih tidak sesuai dengan peran akun Anda',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  context.read<AuthBloc>().add(LogoutRequested(role: 'siswa'));

                  context.go('/select-role');
                } else {
                  // Check if this is a Google sign-in and user is admin stan
                  if (_isGoogleSignIn && state.user.isAdminStan) {
                    // Check if profile is already filled
                    context.read<StanProfileCompletionBloc>().add(
                      CheckStanProfileRequested(userId: state.user.id),
                    );
                    // Reset the flag
                    setState(() {
                      _isGoogleSignIn = false;
                    });
                  } else {
                    // Navigate based on role for non-Google sign-in or other roles
                    if (state.user.isSiswa) {
                      context.go('/siswa-home');
                    } else if (state.user.isAdminStan) {
                      context.go('/complete-stan-profile');
                    } else if (state.user.isSuperAdmin) {
                      context.go('/admin');
                    }
                  }
                }
              }
            },
          ),
          BlocListener<StanProfileCompletionBloc, StanProfileCompletionState>(
            listener: (context, state) {
              if (state is StanProfileSavedSuccessfully) {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  if (authState.user.isAdminStan) {
                    context.go('/admin');
                  } else if (authState.user.isSiswa) {
                    context.go('/siswa-home');
                  } else if (authState.user.isSuperAdmin) {
                    context.go('/admin');
                  }
                }
              } else if (state is StanProfileCompletionError) {
                // Profile doesn't exist, navigate to complete profile screen
                context.go('/complete-stan-profile');
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Container(
              decoration: BoxDecoration(color: AppTheme.backgroundColor),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Selamat Datang👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (widget.selectedRole != null)
                              OutlinedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => context.go('/select-role'),
                                icon: const Icon(Icons.swap_horiz, size: 20),
                                label: const Text('Ganti Peran'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  side: const BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (widget.selectedRole != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.selectedRole == AppConstants.roleSiswa
                                      ? Icons.person
                                      : widget.selectedRole ==
                                            AppConstants.roleAdminStan
                                      ? Icons.store
                                      : Icons.admin_panel_settings,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Peran: ${widget.selectedRole == AppConstants.roleSiswa
                                      ? "Siswa"
                                      : widget.selectedRole == AppConstants.roleAdminStan
                                      ? "Admin Stan"
                                      : "Super Admin"}',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Masukkan email dan password Anda untuk login',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 40),

                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Masukkan email Anda',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Masukkan password Anda',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          enabled: !isLoading,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Login Button
                        PrimaryButton(
                          text: 'Login',
                          onPressed: _handleLogin,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.center,
                          child: Text.rich(
                            TextSpan(
                              text: 'Belum punya akun? ',
                              style: TextStyle(color: Colors.grey[700]),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () => context.push(
                                            '/register',
                                            extra: widget.selectedRole,
                                          ),
                                    child: Text(
                                      'Daftar',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'atau',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Google Sign-In Button
                        PrimaryButton(
                          text: 'Masuk dengan Google',
                          backgroundColor: AppTheme.backgroundColor,
                          textColor: Colors.black87,
                          onPressed: () {
                            setState(() {
                              _isGoogleSignIn = true;
                            });
                            context.read<AuthBloc>().add(
                              GoogleSignInRequested(
                                role:
                                    widget.selectedRole ??
                                    'siswa', // Gunakan role yang dipilih di role selector
                              ),
                            );
                          },
                          isLoading: isLoading,
                          icon: Image.asset(
                            'assets/icons/google-logo.png',
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
