import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/utils/app_utils.dart';
import 'package:kantin_app/core/widgets/app_bottom_nav.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';
import 'package:kantin_app/features/auth/domain/entities/user.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_state.dart'
    as profile_state;
import 'package:kantin_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:kantin_app/features/siswa/domain/entities/siswa.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _logoutRole; // Store role before logout

  @override
  void initState() {
    super.initState();
    // Load siswa profile when screen loads
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.isSiswa) {
      context.read<ProfileBloc>().add(
        GetSiswaProfileRequested(userId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Navigate to login with role parameter from logout
          if (_logoutRole != null) {
            context.go('/login/$_logoutRole');
            _logoutRole = null; // Reset after navigation
          } else {
            context.go('/login');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const _ProfileScaffold(
            currentIndex: 3,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        User? user;
        if (state is Authenticated) {
          user = state.user;
        } else if (state is RegistrationSuccess) {
          user = state.user;
        }

        if (user == null) {
          return _ProfileScaffold(
            currentIndex: 3,
            child: _ProfileError(
              message: 'Tidak dapat memuat profil. Silakan login ulang.',
              onRetry: () {
                context.read<AuthBloc>().add(const AuthStatusChecked());
              },
            ),
          );
        }

        return _ProfileScaffold(
          currentIndex: 3,
          child: _ProfileContent(
            user: user!,
            onLogout: (role) {
              setState(() {
                _logoutRole = role;
              });
              context.read<AuthBloc>().add(LogoutRequested(role: role));
            },
          ),
        );
      },
    );
  }
}

class _ProfileScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const _ProfileScaffold({required this.child, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(child: child),
      bottomNavigationBar: AppBottomNav(currentIndex: currentIndex),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final User user;
  final Function(String role) onLogout;

  const _ProfileContent({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    // Show siswa profile if user is siswa
    if (user.isSiswa) {
      return BlocBuilder<ProfileBloc, profile_state.ProfileState>(
        builder: (context, profileState) {
          if (profileState is profile_state.ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Siswa? siswa;
          if (profileState is profile_state.ProfileLoaded) {
            siswa = profileState.siswa;
          } else if (profileState is profile_state.ProfileUpdateSuccess) {
            siswa = profileState.siswa;
          }

          if (siswa != null) {
            return _SiswaProfileContent(
              user: user,
              siswa: siswa,
              onLogout: onLogout,
            );
          }

          // Error or initial state for siswa
          if (profileState is profile_state.ProfileError) {
            return _ProfileError(
              message: profileState.message,
              onRetry: () {
                context.read<ProfileBloc>().add(
                  GetSiswaProfileRequested(userId: user.id),
                );
              },
            );
          }

          // Loading for first time
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // Show regular profile for non-siswa users
    return _RegularProfileContent(user: user, onLogout: onLogout);
  }
}

class _SiswaProfileContent extends StatelessWidget {
  final User user;
  final Siswa siswa;
  final Function(String role) onLogout;

  const _SiswaProfileContent({
    required this.user,
    required this.siswa,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSiswaHeader(context),
          const SizedBox(height: 16),
          _buildSiswaAccountSection(context),
          const SizedBox(height: 16),
          _buildSettings(context),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Keluar',
            onPressed: () {
              onLogout(user.role);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Terakhir login: ${AppUtils.formatDateTime(user.createdAt)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              image: siswa.foto.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(siswa.foto),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: siswa.foto.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 32)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa.namaSiswa.isNotEmpty ? siswa.namaSiswa : 'Siswa',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                _RoleChip(label: user.role),
                const SizedBox(height: 4),
                Text(
                  'Bergabung ${AppUtils.formatDate(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: EditProfileScreen(siswa: siswa),
                  ),
                ),
              );

              // Reload profile if edit was successful
              if (result == true && context.mounted) {
                context.read<ProfileBloc>().add(
                  GetSiswaProfileRequested(userId: user.id),
                );
              }
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaAccountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Akun',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Nama'),
            subtitle: Text(siswa.namaSiswa),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Alamat'),
            subtitle: Text(siswa.alamat.isEmpty ? '-' : siswa.alamat),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_outlined),
            title: const Text('No. Telepon'),
            subtitle: Text(siswa.telp.isEmpty ? '-' : siswa.telp),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Peran'),
            subtitle: Text(user.role),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _SettingTile(
            icon: Icons.notifications_none,
            title: 'Notifikasi',
            subtitle: 'Kelola preferensi notifikasi',
          ),
          const Divider(height: 1),
          const _SettingTile(
            icon: Icons.payment_outlined,
            title: 'Metode Pembayaran',
            subtitle: 'Simpan kartu atau e-wallet',
          ),
          const Divider(height: 1),
          const _SettingTile(
            icon: Icons.help_outline,
            title: 'Bantuan',
            subtitle: 'FAQ dan pusat bantuan',
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.verified_user_outlined,
            title: 'Privasi & Keamanan',
            subtitle: 'Atur keamanan akun',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan privasi belum tersedia'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RegularProfileContent extends StatelessWidget {
  final User user;
  final Function(String role) onLogout;

  const _RegularProfileContent({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildAccountSection(context),
          const SizedBox(height: 16),
          _buildSettings(context),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Keluar',
            onPressed: () {
              onLogout(user.role);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Terakhir login: ${AppUtils.formatDateTime(user.createdAt)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username.isNotEmpty ? user.username : 'Pengguna',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                _RoleChip(label: user.role),
                const SizedBox(height: 4),
                Text(
                  'Bergabung ${AppUtils.formatDate(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profil belum tersedia')),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Akun',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Nama pengguna'),
            subtitle: Text(user.username),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Peran'),
            subtitle: Text(user.role),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available_outlined),
            title: const Text('Bergabung'),
            subtitle: Text(AppUtils.formatDate(user.createdAt)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _SettingTile(
            icon: Icons.notifications_none,
            title: 'Notifikasi',
            subtitle: 'Kelola preferensi notifikasi',
          ),
          const Divider(height: 1),
          const _SettingTile(
            icon: Icons.payment_outlined,
            title: 'Metode Pembayaran',
            subtitle: 'Simpan kartu atau e-wallet',
          ),
          const Divider(height: 1),
          const _SettingTile(
            icon: Icons.help_outline,
            title: 'Bantuan',
            subtitle: 'FAQ dan pusat bantuan',
          ),
          const Divider(height: 1),
          _SettingTile(
            icon: Icons.verified_user_outlined,
            title: 'Privasi & Keamanan',
            subtitle: 'Atur keamanan akun',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan privasi belum tersedia'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const Spacer(),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;

  const _RoleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            PrimaryButton(text: 'Coba Lagi', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
