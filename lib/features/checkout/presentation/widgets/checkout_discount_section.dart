import 'package:flutter/material.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/cart/domain/entities/cart_item.dart';
import 'package:kantin_app/features/diskon/domain/entities/menu_diskon.dart';

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
          'Diskon Per Menu',
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
                  'Tidak ada diskon untuk menu di keranjang',
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
              Icon(Icons.local_offer, size: 18, color: Colors.orange[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pilih diskon per menu',
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
          ..._buildDiscountSection(
            title: 'Diskon Tersedia',
            context: context,
            cartItems: cartItems,
            menuDiscounts: menuDiscounts,
            enabledMenuDiscounts: enabledMenuDiscounts,
            showEnabled: false,
            onToggleDiscount: onToggleDiscount,
          ),
          const SizedBox(height: 12),
          ..._buildDiscountSection(
            title: 'Diskon Terpakai',
            context: context,
            cartItems: cartItems,
            menuDiscounts: menuDiscounts,
            enabledMenuDiscounts: enabledMenuDiscounts,
            showEnabled: true,
            onToggleDiscount: onToggleDiscount,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiscountSection({
    required String title,
    required BuildContext context,
    required List<CartItem> cartItems,
    required Map<String, Diskon> menuDiscounts,
    required Set<String> enabledMenuDiscounts,
    required bool showEnabled,
    required void Function(String menuId, bool enabled) onToggleDiscount,
  }) {
    final menuNameById = {
      for (final item in cartItems) item.menuId: item.namaItem,
    };

    final entries = menuDiscounts.entries
        .where(
          (entry) => showEnabled
              ? enabledMenuDiscounts.contains(entry.key)
              : !enabledMenuDiscounts.contains(entry.key),
        )
        .toList();

    if (entries.isEmpty) {
      return [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          showEnabled
              ? 'Belum ada diskon dipakai'
              : 'Semua diskon sudah dipakai',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ];
    }

    return [
      Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      ...entries.map((entry) {
        final menuId = entry.key;
        final discount = entry.value;
        final menuName = menuNameById[menuId] ?? 'Menu';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${discount.namaDiskon} • ${discount.persentaseDiskon.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => onToggleDiscount(menuId, !showEnabled),
                child: Text(showEnabled ? 'Batalkan' : 'Gunakan'),
              ),
            ],
          ),
        );
      }),
    ];
  }
}
