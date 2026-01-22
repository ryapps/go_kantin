import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/di/injection_container.dart';
import 'package:kantin_app/features/auth/presentation/screens/login_screen.dart';
import 'package:kantin_app/features/auth/presentation/screens/register_screen.dart';
import 'package:kantin_app/features/auth/presentation/screens/role_selector_screen.dart';
import 'package:kantin_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:kantin_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:kantin_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:kantin_app/features/home/presentation/screens/siswa_home_screen.dart';
import 'package:kantin_app/features/transaksi/presentation/bloc/order_tracking_bloc.dart';
import 'package:kantin_app/features/transaksi/presentation/bloc/transaksi_history_bloc.dart';
import 'package:kantin_app/features/transaksi/presentation/screens/order_tracking_screen.dart';
import 'package:kantin_app/features/transaksi/presentation/screens/transaksi_history_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(selectedRole: state.extra as String?),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            RegisterScreen(selectedRole: state.extra as String?),
      ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) =>
            RoleSelectorScreen(email: state.extra as String?),
      ),

      // Placeholder routes (will be implemented in next phases)
      GoRoute(
        path: '/siswa-home',
        builder: (context, state) => const SiswaHomeScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CheckoutBloc>(),
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: '/stan-orders',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Pesanan Stan',
          message:
              'Stan orders screen akan diimplementasikan di fase berikutnya',
          icon: Icons.receipt_long,
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Admin Dashboard',
          message: 'Admin dashboard akan diimplementasikan di fase berikutnya',
          icon: Icons.admin_panel_settings,
        ),
      ),
      GoRoute(
        path: '/complete-siswa-profile',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Lengkapi Profile',
          message:
              'Profile completion akan diimplementasikan di fase berikutnya',
          icon: Icons.person,
        ),
      ),
      GoRoute(
        path: '/complete-stan-profile',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Lengkapi Data Stan',
          message: 'Stan profile akan diimplementasikan di fase berikutnya',
          icon: Icons.store,
        ),
      ),
      GoRoute(
        path: '/order-tracking/:id',
        builder: (context, state) {
          final transaksiId = state.pathParameters['id'] ?? '';
          return BlocProvider(
            create: (context) => sl<OrderTrackingBloc>(),
            child: OrderTrackingScreen(transaksiId: transaksiId),
          );
        },
      ),
      GoRoute(
        path: '/transaksi-history',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<TransaksiHistoryBloc>(),
          child: const TransaksiHistoryScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${state.error}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Placeholder screen for routes not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Add logout functionality here
              context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Dalam Pengembangan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
