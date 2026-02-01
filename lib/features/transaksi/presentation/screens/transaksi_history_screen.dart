import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/utils/app_utils.dart';
import 'package:kantin_app/core/utils/constants.dart';
import 'package:kantin_app/core/widgets/app_bottom_nav.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';

import '../bloc/transaksi_history_bloc.dart';
import '../bloc/transaksi_history_event.dart';
import '../bloc/transaksi_history_state.dart';

class TransaksiHistoryScreen extends StatefulWidget {
  const TransaksiHistoryScreen({super.key});

  @override
  State<TransaksiHistoryScreen> createState() => _TransaksiHistoryScreenState();
}

class _TransaksiHistoryScreenState extends State<TransaksiHistoryScreen> {
  String? _selectedMonthKey;

  @override
  void initState() {
    super.initState();
    context.read<TransaksiHistoryBloc>().add(const TransaksiHistoryStarted());
  }

  @override
  Widget build(BuildContext context) {
    const tabBar = TabBar(
      labelPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      unselectedLabelStyle: TextStyle(color: Colors.black54),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      tabs: [
        Tab(text: 'Semua'),
        Tab(text: 'Dalam \nProses'),
        Tab(text: 'Selesai'),
        Tab(text: 'Dibatalkan'),
      ],
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Aktivitas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: false,
          backgroundColor: AppTheme.backgroundColor,
        ),
        body: Column(
          children: [
            tabBar,
            Expanded(
              child: BlocBuilder<TransaksiHistoryBloc, TransaksiHistoryState>(
                builder: (context, state) {
                  if (state is TransaksiHistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TransaksiHistoryError) {
                    return _buildError(state.message);
                  }

                  if (state is TransaksiHistoryEmpty) {
                    return _buildEmpty();
                  }

                  if (state is TransaksiHistoryLoaded) {
                    final all = _applyMonthFilter(state.transaksi);
                    final dalamProses = all
                        .where(
                          (item) =>
                              item.status ==
                                  AppConstants.statusBelumDikonfirm ||
                              item.status == AppConstants.statusDimasak ||
                              item.status == AppConstants.statusDiantar,
                        )
                        .toList();
                    final selesai = all
                        .where(
                          (item) => item.status == AppConstants.statusSampai,
                        )
                        .toList();
                    final dibatalkan = all
                        .where(
                          (item) =>
                              item.status == AppConstants.statusDibatalkan,
                        )
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 16),
                        _buildMonthFilter(context, state.transaksi),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildHistoryList(context, all),
                              _buildHistoryList(context, dalamProses),
                              _buildHistoryList(context, selesai),
                              _buildHistoryList(context, dibatalkan),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<Transaksi> transaksi) {
    if (transaksi.isEmpty) {
      return _buildEmpty();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = transaksi[index];
        return _buildHistoryCard(context, item);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: transaksi.length,
    );
  }

  Widget _buildMonthFilter(BuildContext context, List<Transaksi> transaksi) {
    final options = _buildMonthOptions(transaksi);
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveValue = options.containsKey(_selectedMonthKey)
        ? _selectedMonthKey
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: 194,
      alignment: Alignment.centerLeft,
      child: DropdownButtonFormField<String?>(
        value: effectiveValue,
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Semua'),
          ),
          ...options.entries.map(
            (entry) => DropdownMenuItem<String?>(
              value: entry.key,
              child: Text(entry.value),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedMonthKey = value;
          });
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.borderColor),
          ),
        ),
      ),
    );
  }

  List<Transaksi> _applyMonthFilter(List<Transaksi> transaksi) {
    if (_selectedMonthKey == null) return transaksi;
    final key = _selectedMonthKey!;
    return transaksi.where((item) {
      final date = item.createdAt;
      final monthKey =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
      return monthKey == key;
    }).toList();
  }

  Map<String, String> _buildMonthOptions(List<Transaksi> transaksi) {
    final map = <String, String>{};
    for (final item in transaksi) {
      final date = item.createdAt;
      final key =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
      final label = '${AppUtils.getIndonesianMonth(date.month)} ${date.year}';
      map.putIfAbsent(key, () => label);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in sortedKeys) key: map[key]!};
  }

  Widget _buildHistoryCard(BuildContext context, Transaksi transaksi) {
    final statusLabel = AppUtils.getStatusLabel(transaksi.status);
    print(transaksi);
    return GestureDetector(
      onTap: () {
        context.push(
          '/order-tracking/${transaksi.id}',
          extra: {'id': transaksi.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
                Expanded(
                  child: Text(
                    transaksi.stanName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppUtils.formatDateTime(transaksi.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  AppUtils.formatCurrency(transaksi.finalAmount),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text('Belum ada transaksi'),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Coba Lagi',
              onPressed: () {
                context.read<TransaksiHistoryBloc>().add(
                  const TransaksiHistoryStarted(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
