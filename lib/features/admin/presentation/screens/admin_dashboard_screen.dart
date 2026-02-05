import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/bloc/get_user_stan_bloc.dart';
import 'package:kantin_app/core/bloc/get_user_stan_event.dart';
import 'package:kantin_app/core/bloc/get_user_stan_state.dart';
import 'package:kantin_app/core/di/injection_container.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/dashboard_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/dashboard_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/dashboard_state.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_report_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/stan_profile_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/stan_profile_event.dart';
import 'package:kantin_app/features/admin/presentation/screens/customer_management_screen.dart';
import 'package:kantin_app/features/admin/presentation/screens/menu_management_screen.dart';
import 'package:kantin_app/features/admin/presentation/screens/order_management_screen.dart';
import 'package:kantin_app/features/admin/presentation/screens/reports_screen.dart';
import 'package:kantin_app/features/admin/presentation/screens/stan_profile_screen.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:kantin_app/features/category/presentation/bloc/category_management_bloc.dart';
import 'package:kantin_app/features/category/presentation/screens/category_management_screen.dart';
import 'package:kantin_app/features/diskon/presentation/bloc/diskon_management_bloc.dart';
import 'package:kantin_app/features/diskon/presentation/screens/diskon_management_screen.dart';

/// Admin Dashboard - Main screen with drawer navigation
class AdminDashboardScreen extends StatefulWidget {
  final String initialRoute;

  const AdminDashboardScreen({super.key, this.initialRoute = 'dashboard'});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _currentRoute = 'dashboard';
  String _stanId = '';
  StreamSubscription? _getUserStanSubscription;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute;
    _loadStanId();
  }

  void _loadStanId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<GetUserStanBloc>().add(LoadUserStanId(authState.user.id));
      _getUserStanSubscription = context.read<GetUserStanBloc>().stream.listen((
        state,
      ) {
        if (state is GetUserStanSuccess && mounted) {
          setState(() {
            _stanId = state.stanId;
          });
          // Reload dashboard data after stanId is loaded

          final dashboardBloc = context.read<DashboardBloc>();
          dashboardBloc.add(LoadDashboardSummary(_stanId));
        }
      });
    }
  }

  @override
  void dispose() {
    _getUserStanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login/admin_stan');
        } else if (state is Authenticated && !state.user.isAdminStan) {
          context.go('/siswa-home');
        }
      },
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle()),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifikasi belum tersedia')),
                  );
                },
              ),
            ],
          ),
          drawer: _buildDrawer(context, state.user.username),
          body: _buildBody(),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_currentRoute) {
      case 'dashboard':
        return 'Dashboard Admin';
      case 'profile':
        return 'Profil Stan';
      case 'menu':
        return 'Kelola Menu';
      case 'categories':
        return 'Kelola Kategori';
      case 'discounts':
        return 'Kelola Diskon';
      case 'orders':
        return 'Kelola Pesanan';
      case 'customers':
        return 'Data Pelanggan';
      case 'reports':
        return 'Laporan';
      default:
        return 'Admin Stan';
    }
  }

  Widget _buildDrawer(BuildContext context, String username) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.store,
                    size: 32,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const Text(
                  'Admin Stan',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: 'dashboard',
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.store_outlined,
            title: 'Profil Stan',
            route: 'profile',
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.restaurant_menu,
            title: 'Kelola Menu',
            route: 'menu',
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.category_outlined,
            title: 'Kelola Kategori',
            route: 'categories',
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.local_offer_outlined,
            title: 'Kelola Diskon',
            route: 'discounts',
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Kelola Pesanan',
            route: 'orders',
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            title: 'Data Pelanggan',
            route: 'customers',
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart,
            title: 'Laporan',
            route: 'reports',
            context: context,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengaturan belum tersedia')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Bantuan'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bantuan belum tersedia')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Keluar'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AuthBloc>().add(
                          const LogoutRequested(role: 'admin_stan'),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String route,
    required BuildContext context,
  }) {
    final isSelected = _currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : null),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      onTap: () {
        setState(() => _currentRoute = route);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody() {
    switch (_currentRoute) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'profile':
        return BlocProvider(
          create: (context) =>
              sl<StanProfileBloc>()..add(LoadStanProfile(_stanId)),
          child: const StanProfileScreen(),
        );
      case 'menu':
        if (_stanId.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return BlocProvider(
          create: (context) =>
              sl<MenuManagementBloc>()..add(LoadMenuItems(_stanId)),
          child: MenuManagementScreen(stanId: _stanId),
        );
      case 'categories':
        return BlocProvider(
          create: (context) => sl<CategoryManagementBloc>(),
          child: const CategoryManagementScreen(),
        );
      case 'discounts':
        if (_stanId.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return BlocProvider(
          create: (context) => sl<DiskonManagementBloc>(),
          child: DiskonManagementScreen(stanId: _stanId),
        );
      case 'orders':
        if (_stanId.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return BlocProvider(
          create: (context) =>
              sl<OrderManagementBloc>()..add(LoadOrders(_stanId)),
          child: OrderManagementScreen(stanId: _stanId),
        );
      case 'customers':
        if (_stanId.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return BlocProvider(
          create: (context) =>
              sl<CustomerManagementBloc>()..add(LoadCustomers(_stanId)),
          child: CustomerManagementScreen(stanId: _stanId),
        );
      case 'reports':
        if (_stanId.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return BlocProvider(
          create: (context) => sl<OrderReportBloc>(),
          child: ReportsScreen(stanId: _stanId),
        );
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_stanId.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data stan...'),
          ],
        ),
      );
    }

    print('Building dashboard for stanId: $_stanId');

    return BlocProvider(
      create: (context) =>
          sl<DashboardBloc>()..add(LoadDashboardSummary(_stanId)),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Hari Ini',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Pesanan Baru',
                          value: state.newOrders.toString(),
                          icon: Icons.shopping_bag,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Diproses',
                          value: state.inProcess.toString(),
                          icon: Icons.schedule,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Selesai',
                          value: state.completed.toString(),
                          icon: Icons.check_circle,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Pemasukan',
                          value: 'Rp ${state.revenue.toStringAsFixed(0)}',
                          icon: Icons.payments,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Statistik Tambahan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Pelanggan',
                          value: state.totalCustomers.toString(),
                          icon: Icons.people,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Menu',
                          value: state.totalMenuItems.toString(),
                          icon: Icons.restaurant_menu,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (state.topSellingItems.isNotEmpty) ...[
                    Text(
                      'Menu Terlaris',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: state.topSellingItems
                            .take(5)
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.local_restaurant,
                                      color: AppTheme.primaryColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(item)),
                                    const Icon(
                                      Icons.arrow_upward,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Menu Aksi Cepat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionCard(
                    title: 'Tambah Menu Baru',
                    subtitle: 'Kelola item menu Anda',
                    icon: Icons.add_circle_outline,
                    onTap: () => setState(() => _currentRoute = 'menu'),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    title: 'Lihat Pesanan Masuk',
                    subtitle: 'Kelola pesanan pelanggan',
                    icon: Icons.notifications_active_outlined,
                    onTap: () => setState(() => _currentRoute = 'orders'),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    title: 'Lihat Laporan',
                    subtitle: 'Analisis penjualan & pemasukan',
                    icon: Icons.assessment_outlined,
                    onTap: () => setState(() => _currentRoute = 'reports'),
                  ),
                ],
              ),
            );
          } else if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Gagal memuat data dashboard: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Retry loading the dashboard
                      final dashboardBloc = context.read<DashboardBloc>();
                      dashboardBloc.add(LoadDashboardSummary(_stanId));
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
