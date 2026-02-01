import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_state.dart';
import 'package:kantin_app/features/admin/presentation/screens/customer_detail_screen.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:kantin_app/features/auth/domain/entities/user.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_state.dart';

class CustomerManagementScreen extends StatefulWidget {
  final String stanId;

  const CustomerManagementScreen({super.key, required this.stanId});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerManagementBloc>().add(LoadCustomers(widget.stanId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCustomerDetail(CustomerInfo customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<CustomerManagementBloc>(),
          child: CustomerDetailScreen(
            customer: customer,
            stanId: widget.stanId,
          ),
        ),
      ),
    );
  }

  void _showCreateCustomerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController(text: 'siswa');
    final passwordController = TextEditingController();

    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Pelanggan Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: roleController,
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {
                      // Notify AuthBloc that admin is creating a customer
                      context.read<AuthBloc>().add(
                        const AdminCreatingCustomerStarted(),
                      );

                      // Show a snackbar to inform admin about the process
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Membuat akun pelanggan...'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      context.read<CustomerManagementBloc>().add(
                        CreateCustomer(
                          userId: '', // Will be auto-generated by Firebase Auth
                          name: nameController.text,
                          email: emailController.text,
                          role: roleController.text,
                          password: passwordController.text,
                        ),
                      );

                      // Close the dialog after submitting
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateCustomerDialog(CustomerInfo customer) {
    final nameController = TextEditingController(text: customer.siswaName);
    final emailController = TextEditingController(text: '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pelanggan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Ubah nama pelanggan',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Ubah email pelanggan',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CustomerManagementBloc>().add(
                UpdateCustomer(
                  customerId: customer.siswaId,
                  name: nameController.text.isNotEmpty
                      ? nameController.text
                      : null,
                  email: emailController.text.isNotEmpty
                      ? emailController.text
                      : null,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(CustomerInfo customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus pelanggan ${customer.siswaName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CustomerManagementBloc>().add(
                DeleteCustomer(customer.siswaId),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCustomerDialog,
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pelanggan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CustomerManagementBloc>().add(
                            const SearchCustomers(''),
                          );
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (query) {
                context.read<CustomerManagementBloc>().add(
                  SearchCustomers(query),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Customer List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerManagementBloc>().add(
                  LoadCustomers(widget.stanId),
                );
              },
              child: BlocConsumer<CustomerManagementBloc, CustomerManagementState>(
                listener: (context, state) {
                  if (state is CustomerCreated) {
                    // Get the current admin user to restore after customer creation
                    final authState = context.read<AuthBloc>().state;
                    User? originalAdminUser;
                    if (authState is Authenticated) {
                      originalAdminUser = authState.user;
                    }

                    // Notify AuthBloc that admin has completed customer creation
                    context.read<AuthBloc>().add(
                      AdminCreatingCustomerCompleted(
                        originalAdminUser: originalAdminUser,
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pelanggan berhasil ditambahkan'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  } else if (state is CustomerUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pelanggan berhasil diperbarui'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  } else if (state is CustomerDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pelanggan berhasil dihapus'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  } else if (state is CustomerManagementError) {
                    // If there was an error, still notify AuthBloc to reset the flag
                    // Get the current admin user to restore after customer creation
                    final authState = context.read<AuthBloc>().state;
                    User? originalAdminUser;
                    if (authState is Authenticated) {
                      originalAdminUser = authState.user;
                    }

                    context.read<AuthBloc>().add(
                      AdminCreatingCustomerCompleted(
                        originalAdminUser: originalAdminUser,
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CustomerManagementLoading) {
                    // Only show circular indicator during initial load, not during refresh
                    // This prevents double indicators during pull-to-refresh
                    // Check if we're in the initial loading state (not coming from a loaded state)
                    if (context.read<CustomerManagementBloc>().state is! CustomersLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // If we reach here, it means we're refreshing but the state is still loading
                    // So we return an empty SizedBox to let RefreshIndicator handle the loading state
                    return const SizedBox();
                  }

                  if (state is CustomerManagementError) {
                    if (state.message.contains('berhasil')) {
                      // Skip showing success messages as errors here since they're handled in listener
                      return const SizedBox();
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CustomerManagementBloc>().add(
                                LoadCustomers(widget.stanId),
                              );
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CustomersLoaded) {
                    if (state.filteredCustomers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.searchQuery != null &&
                                      state.searchQuery!.isNotEmpty
                                  ? 'Tidak ada pelanggan yang ditemukan'
                                  : 'Belum ada pelanggan',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pelanggan akan muncul setelah melakukan pesanan',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: state.filteredCustomers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final customer = state.filteredCustomers[index];
                        return _buildCustomerCard(customer, index + 1);
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerInfo customer, int rank) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCustomerDetail(customer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  customer.siswaName.isNotEmpty
                      ? customer.siswaName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info pelanggan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.siswaName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.totalOrders} pesanan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (customer.lastOrderDate != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Terakhir: ${dateFormat.format(customer.lastOrderDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Total belanja + menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'view') {
                        _showCustomerDetail(customer);
                      } else if (action == 'edit') {
                        _showUpdateCustomerDialog(customer);
                      } else if (action == 'delete') {
                        _showDeleteConfirmationDialog(customer);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('Lihat Detail'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Hapus'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${customer.totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'Total Belanja',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
