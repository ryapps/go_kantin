import 'package:flutter/material.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/cart/domain/entities/cart_item.dart';
import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';

class CheckoutDiscountSection extends StatelessWidget {
  final List<CartItem> cartItems;
  final Map<String, Diskon> menuDiscounts;
  final Set<String> enabledMenuDiscounts;
  final void Function(String menuId, bool enabled) onToggleDiscount;

  const CheckoutDiscountSection({
    super.key,
    required this.cartItems,
    required this.menuDiscounts,
    required this.enabledMenuDiscounts,
    required this.onToggleDiscount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diskon Kantin',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (menuDiscounts.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: Colors.grey[500]),
                const SizedBox(width: 10),
                Text(
                  'Tidak ada diskon untuk kantin ini',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          CheckoutDiscountInfoCard(
            cartItems: cartItems,
            menuDiscounts: menuDiscounts,
            enabledMenuDiscounts: enabledMenuDiscounts,
            onToggleDiscount: onToggleDiscount,
          ),
      ],
    );
  }
}

class CheckoutDiscountInfoCard extends StatelessWidget {
  final List<CartItem> cartItems;
  final Map<String, Diskon> menuDiscounts;
  final Set<String> enabledMenuDiscounts;
  final void Function(String menuId, bool enabled) onToggleDiscount;

  const CheckoutDiscountInfoCard({
    super.key,
    required this.cartItems,
    required this.menuDiscounts,
    required this.enabledMenuDiscounts,
    required this.onToggleDiscount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Diskon Kantin Tersedia',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._buildStanDiscountSection(
            context: context,
            cartItems: cartItems,
            menuDiscounts: menuDiscounts,
            enabledMenuDiscounts: enabledMenuDiscounts,
            onToggleDiscount: onToggleDiscount,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStanDiscountSection({
    required BuildContext context,
    required List<CartItem> cartItems,
    required Map<String, Diskon> menuDiscounts,
    required Set<String> enabledMenuDiscounts,
    required void Function(String menuId, bool enabled) onToggleDiscount,
  }) {
    if (menuDiscounts.isEmpty || cartItems.isEmpty) {
      return [
        Text(
          'Tidak ada diskon aktif',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ];
    }

    final stanId = cartItems.first.stanId;
    final discount = menuDiscounts.values.first;
    final isEnabled = enabledMenuDiscounts.contains(stanId);

    return [
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    discount.namaDiskon,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Diskon ${discount.persentaseDiskon.toStringAsFixed(0)}% untuk semua menu',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => onToggleDiscount(stanId, !isEnabled),
              child: Text(isEnabled ? 'Batalkan' : 'Gunakan'),
            ),
          ],
        ),
      ),
    ];
  }
}
