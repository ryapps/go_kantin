import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/utils/app_utils.dart';
import 'package:kantin_app/core/utils/constants.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';

import '../bloc/order_tracking_bloc.dart';
import '../bloc/order_tracking_event.dart';
import '../bloc/order_tracking_state.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String transaksiId;

  const OrderTrackingScreen({super.key, required this.transaksiId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderTrackingBloc>().add(
      OrderTrackingStarted(widget.transaksiId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Status Pesanan',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            context.go('/transaksi-history');
          },
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
      ),
      body: BlocBuilder<OrderTrackingBloc, OrderTrackingState>(
        builder: (context, state) {
          if (state is OrderTrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderTrackingError) {
            return _buildError(state.message);
          }

          if (state is OrderTrackingLoaded) {
            return _buildContent(context, state.transaksi);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Transaksi transaksi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(context, transaksi),
          const SizedBox(height: 16),
          _buildStatusSection(context, transaksi),
          const SizedBox(height: 16),
          _buildItemsSection(context, transaksi),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, Transaksi transaksi) {
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
            AppUtils.generateOrderNumber(transaksi.id),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Kantin', transaksi.stanName),
          _buildSummaryRow(
            'Subtotal',
            AppUtils.formatCurrency(transaksi.totalAmount),
          ),
          _buildSummaryRow(
            'Diskon',
            '- ${AppUtils.formatCurrency(transaksi.totalDiscount)}',
          ),
          _buildSummaryRow(
            'Total',
            AppUtils.formatCurrency(transaksi.finalAmount),
          ),
          _buildSummaryRow(
            'Waktu',
            AppUtils.formatDateTime(transaksi.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, Transaksi transaksi) {
    if (transaksi.isCancelled) {
      return _buildCancelledCard(context, transaksi);
    }

    final steps = [
      AppConstants.statusBelumDikonfirm,
      AppConstants.statusDimasak,
      AppConstants.statusDiantar,
      AppConstants.statusSampai,
    ];
    final currentIndex = steps.indexOf(transaksi.status);

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
            'Proses Pesanan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isActive = index <= (currentIndex == -1 ? 0 : currentIndex);
            final isCurrent = index == (currentIndex == -1 ? 0 : currentIndex);
            return _buildStatusStep(
              context: context,
              status: status,
              isActive: isActive,
              isCurrent: isCurrent,
              isLast: index == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, Transaksi transaksi) {
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
            'Detail Pesanan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...transaksi.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaMakanan,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.qty} x ${AppUtils.formatCurrency(item.hargaBeli)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        if (item.discountAmount > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Diskon: - ${AppUtils.formatCurrency(item.discountAmount)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.orange[700]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    AppUtils.formatCurrency(item.subtotal),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep({
    required BuildContext context,
    required String status,
    required bool isActive,
    required bool isCurrent,
    required bool isLast,
  }) {
    final color = isActive ? AppTheme.primaryColor : AppTheme.borderColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: color, width: 2),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
            if (!isLast) Container(width: 2, height: 28, color: color),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              AppUtils.getStatusLabel(status),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppTheme.textPrimary : AppTheme.textDisabled,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledCard(BuildContext context, Transaksi transaksi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel, color: AppTheme.errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pesanan dibatalkan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 64),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
