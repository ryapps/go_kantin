import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
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
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
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
          const SizedBox(height: 16),
          // Show cancel button only if status is 'belum_dikonfirm' and order is not cancelled
          if (transaksi.status == AppConstants.statusBelumDikonfirm &&
              !transaksi.isCancelled)
            _buildCancelButton(context, transaksi),
          // Show save receipt button only if status is 'sampai' (completed)
          if (transaksi.status == AppConstants.statusSampai)
            _buildSaveReceiptButton(context, transaksi),
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

  Widget _buildCancelButton(BuildContext context, Transaksi transaksi) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _confirmCancellation(context, transaksi);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Batalkan Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  void _confirmCancellation(BuildContext context, Transaksi transaksi) {
    // Get the bloc instance before opening the dialog
    final orderTrackingBloc = context.read<OrderTrackingBloc>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembatalan'),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan pesanan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Dispatch the cancel order event using the bloc instance
                orderTrackingBloc.add(
                  CancelOrderRequested(transaksiId: transaksi.id),
                );
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
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

  Widget _buildSaveReceiptButton(BuildContext context, Transaksi transaksi) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _saveReceiptImage(transaksi);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_outlined, size: 18),
            SizedBox(width: 8),
            Text(
              'Simpan Bukti Pemesanan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  final GlobalKey _receiptKey = GlobalKey();

  Future<void> _saveReceiptImage(Transaksi transaksi) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Menyimpan Bukti Pemesanan...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );

      // Create image from widget
      final imageBytes = await _captureReceiptAsImage(transaksi);

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        name:
            "Bukti_Pemesanan_${transaksi.id}_${DateTime.now().millisecondsSinceEpoch}",
        quality: 100,
      );

      // Dismiss loading dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show result
      if (result != null && result['isSuccess']) {
        _showSuccessMessage('Bukti pemesanan berhasil disimpan di galeri');
      } else {
        _showErrorMessage('Gagal menyimpan bukti pemesanan');
      }
    } catch (e) {
      print('Error saving receipt: $e');
      // Dismiss loading dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showErrorMessage('Terjadi kesalahan saat menyimpan bukti pemesanan');
    }
  }

  Future<Uint8List> _captureReceiptAsImage(Transaksi transaksi) async {
    final repaintBoundary = GlobalKey();

    // Create a widget that will be rendered offscreen
    final widget = RepaintBoundary(
      key: repaintBoundary,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white),
            child: _buildReceiptContent(transaksi),
          ),
        ),
      ),
    );

    // Create an overlay entry to render the widget offscreen
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -10000, // Position offscreen
        top: -10000,
        child: Material(color: Colors.transparent, child: widget),
      ),
    );

    // Add to overlay
    Overlay.of(context).insert(overlayEntry);

    // Wait for the widget to be rendered
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // Capture the image
      final boundary =
          repaintBoundary.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('RenderRepaintBoundary not found');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      return byteData.buffer.asUint8List();
    } finally {
      // Remove the overlay entry
      overlayEntry.remove();
    }
  }

  Widget _buildReceiptContent(Transaksi transaksi) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header
        const Text(
          'SMK Telkom Malang',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Jl. Danau Ranau, Sawojajar, Kec. Kedungkandang, Kota Malang', style: TextStyle(fontSize: 12),textAlign: TextAlign.center,),
        const SizedBox(height: 4),
        const Text('Telp: 0812-2348-8999', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 16),

        // Divider
        Container(
          height: 1,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),

        // Order Info
        const Text(
          'BUKTI PEMESANAN',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppUtils.generateOrderNumber(transaksi.id),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Customer and Stan Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pelanggan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(transaksi.siswaName, textAlign: TextAlign.right),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kantin:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(transaksi.stanName, textAlign: TextAlign.right),
          ],
        ),
        const SizedBox(height: 16),

        // Items
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Rincian Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        ...transaksi.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text('${item.qty}x ${item.namaMakanan}'),
                ),
                Expanded(
                  child: Text(
                    AppUtils.formatCurrency(item.hargaBeli),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subtotal:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(AppUtils.formatCurrency(transaksi.totalAmount)),
          ],
        ),

        // Discount
        if (transaksi.totalDiscount > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diskon:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('-${AppUtils.formatCurrency(transaksi.totalDiscount)}'),
            ],
          ),
        ],

        // Total
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              AppUtils.formatCurrency(transaksi.finalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),

        // Payment Method
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Metode Pembayaran:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(transaksi.paymentMethod ?? 'Tunai'),
          ],
        ),
        // Time
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tanggal:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(AppUtils.formatDateTime(transaksi.createdAt)),
          ],
        ),

        // Footer
        const SizedBox(height: 24),
        Container(
          height: 1,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        const SizedBox(height: 8),
        const Text(
          'Terima kasih telah berbelanja!',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        Text(
          'Status: ${AppUtils.getStatusLabel(transaksi.status)}',
          style: const TextStyle(
            color: AppTheme.successColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.successColor),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }
}
