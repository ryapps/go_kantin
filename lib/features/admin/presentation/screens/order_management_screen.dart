import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/utils/app_utils.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_management_state.dart';
import 'package:kantin_app/features/admin/presentation/screens/order_detail_screen.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';

class OrderManagementScreen extends StatefulWidget {
  final String stanId;

  const OrderManagementScreen({super.key, required this.stanId});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String? _selectedStatus;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrderManagementBloc>().add(LoadOrders(widget.stanId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'belum_dikonfirm':
        return Icons.notifications_active;
      case 'dimasak':
        return Icons.restaurant;
      case 'diantar':
        return Icons.delivery_dining;
      case 'sampai':
        return Icons.check_circle;
      case 'dibatalkan':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _showOrderDetail(Transaksi order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<OrderManagementBloc>(),
        child: OrderDetailScreen(order: order),
      ),
    );
  }

  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with stats
          BlocBuilder<OrderManagementBloc, OrderManagementState>(
            builder: (context, state) {
              if (state is OrderManagementLoaded) {
                final counts = state.statusCounts;
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Baru',
                              counts['belum_dikonfirm'] ?? 0,
                              Colors.orange,
                              Icons.notifications_active,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Dimasak',
                              counts['dimasak'] ?? 0,
                              Colors.blue,
                              Icons.restaurant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Diantar',
                              counts['diantar'] ?? 0,
                              Colors.purple,
                              Icons.delivery_dining,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Selesai',
                              counts['sampai'] ?? 0,
                              AppTheme.successColor,
                              Icons.check_circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          const Divider(height: 1),

          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama siswa...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<OrderManagementBloc>().add(
                                const SearchOrders(''),
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
                    context.read<OrderManagementBloc>().add(
                      SearchOrders(query),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Month filter row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DateTime>(
                            isExpanded: true,
                            hint: const Text('  Pilih Bulan'),
                            value: _selectedMonth,
                            onChanged: (DateTime? newValue) {
                              setState(() {
                                _selectedMonth = newValue;
                              });
                              // Trigger month filter event
                              if (newValue != null) {
                                context.read<OrderManagementBloc>().add(
                                  FilterOrdersByMonth(
                                    widget.stanId,
                                    newValue.month,
                                    newValue.year,
                                  ),
                                );
                              } else {
                                // If no month is selected, reload all orders
                                context.read<OrderManagementBloc>().add(
                                  LoadOrders(widget.stanId),
                                );
                              }
                            },
                            items: _generateMonthYearOptions().map((date) {
                              return DropdownMenuItem<DateTime>(
                                value: date,
                                child: Text(
                                  '  ${AppUtils.formatMonthYearIndonesian(date)}',
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Reset button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMonth = null;
                        });
                        context.read<OrderManagementBloc>().add(
                          LoadOrders(widget.stanId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', null),
                      const SizedBox(width: 8),
                      _buildFilterChip('Baru', 'belum_dikonfirm'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Dimasak', 'dimasak'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Diantar', 'diantar'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Selesai', 'sampai'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Order List
          Expanded(
            child: BlocConsumer<OrderManagementBloc, OrderManagementState>(
              listener: (context, state) {
                if (state is OrderManagementSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (state is OrderManagementError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is OrderManagementLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OrderManagementError) {
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
                            context.read<OrderManagementBloc>().add(
                              LoadOrders(widget.stanId),
                            );
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OrderManagementLoaded) {
                  if (state.filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery != null &&
                                    state.searchQuery!.isNotEmpty
                                ? 'Tidak ada pesanan yang ditemukan'
                                : (state.statusFilter != null || _selectedMonth != null)
                                ? 'Tidak ada pesanan dengan filter ini'
                                : 'Belum ada pesanan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<OrderManagementBloc>().add(
                        RefreshOrders(widget.stanId),
                      );
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical:16),
                      itemCount: state.filteredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = state.filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _generateMonthYearOptions() {
    List<DateTime> options = [];

    // Generate options for the past 12 months including current month
    for (int i = 0; i < 12; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i * 30));
      // Normalize to first day of the month
      DateTime normalizedDate = DateTime(date.year, date.month, 1);

      // Avoid duplicates by checking if this year-month combination already exists
      if (!options.any((option) =>
          option.year == normalizedDate.year &&
          option.month == normalizedDate.month)) {
        options.add(normalizedDate);
      }
    }

    // Sort in descending order (most recent first)
    options.sort((a, b) => b.compareTo(a));

    return options;
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? filterValue) {
    final isSelected = _selectedStatus == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = filterValue);
        context.read<OrderManagementBloc>().add(
          FilterOrdersByStatus(filterValue),
        );
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildOrderCard(Transaksi order) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(order.status),
                      color: _getStatusColor(order.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.siswaName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(order.status)),
                    ),
                    child: Text(
                      _getStatusLabel(order.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ...order.items
                  .take(2)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            '${item.qty}x',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.namaMakanan,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            'Rp ${item.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (order.items.length > 2)
                Text(
                  '+ ${order.items.length - 2} item lainnya',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    'Rp ${order.finalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
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
