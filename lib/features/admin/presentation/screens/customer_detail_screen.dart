import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_state.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerInfo customer;
  final String stanId;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    required this.stanId,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerManagementBloc>().add(
      LoadCustomerDetails(widget.customer.siswaId, widget.stanId),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'belum_dikonfirm':
        return 'Baru';
      case 'dimasak':
        return 'Dimasak';
      case 'diantar':
        return 'Diantar';
      case 'sampai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'belum_dikonfirm':
        return Colors.orange;
      case 'dimasak':
        return Colors.blue;
      case 'diantar':
        return Colors.purple;
      case 'sampai':
        return AppTheme.successColor;
      case 'dibatalkan':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CustomerManagementBloc, CustomerManagementState>(
        builder: (context, state) {
          if (state is CustomerDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerManagementError) {
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
                        LoadCustomerDetails(
                          widget.customer.siswaId,
                          widget.stanId,
                        ),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is CustomerDetailsLoaded) {
            final customer = widget.customer;
            final transactions = state.transactions;

            // Calculate additional stats based on transactions
            final completedOrders = transactions
                .where((t) => t.status == 'sampai')
                .length;
            final cancelledOrders = transactions
                .where((t) => t.status == 'dibatalkan')
                .length;
            final totalSpentFromTransactions = transactions
                .where((t) => t.status == 'sampai')
                .fold(0.0, (sum, t) => sum + t.finalAmount);
            final averageOrderValue = completedOrders > 0
                ? totalSpentFromTransactions / completedOrders
                : 0.0;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Customer Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            customer.siswaName.isNotEmpty
                                ? customer.siswaName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          customer.siswaName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${customer.siswaId.length > 8 ? customer.siswaId.substring(0, 8) : customer.siswaId}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Pesanan',
                                customer.totalOrders.toString(),
                                Icons.shopping_bag,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Selesai',
                                completedOrders.toString(),
                                Icons.check_circle,
                                AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Belanja',
                                'Rp ${customer.totalSpent.toStringAsFixed(0)}',
                                Icons.payments,
                                AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Rata-rata',
                                'Rp ${averageOrderValue.toStringAsFixed(0)}',
                                Icons.trending_up,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        if (cancelledOrders > 0) ...[
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Pesanan Dibatalkan',
                            cancelledOrders.toString(),
                            Icons.cancel,
                            AppTheme.errorColor,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Transaction History
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (transactions.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'Belum ada transaksi',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                        else
                          ...transactions.map(
                            (transaction) => _buildTransactionCard(
                              transaction,
                              dateFormat,
                              timeFormat,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    Transaksi transaction,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(transaction.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(transaction.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const Divider(height: 16),
            ...transaction.items
                .take(2)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '${item.qty}x',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.namaMakanan,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (transaction.items.length > 2)
              Text(
                '+ ${transaction.items.length - 2} item lainnya',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                Text(
                  'Rp ${transaction.finalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
