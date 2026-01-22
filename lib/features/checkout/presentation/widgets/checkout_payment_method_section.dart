import 'package:flutter/material.dart';
import 'package:kantin_app/core/theme/app_theme.dart';

class CheckoutPaymentMethodSection extends StatelessWidget {
  final String? selectedPaymentMethod;
  final ValueChanged<String> onSelected;

  const CheckoutPaymentMethodSection({
    super.key,
    required this.selectedPaymentMethod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...['cash', 'transfer', 'ewallet'].map((method) {
          final labels = {
            'cash': {'name': 'Tunai', 'icon': Icons.money},
            'transfer': {
              'name': 'Transfer Bank',
              'icon': Icons.account_balance,
            },
            'ewallet': {'name': 'E-Wallet', 'icon': Icons.wallet_membership},
          };

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: RadioListTile(
              value: method,
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) {
                  onSelected(value);
                }
              },
              title: Row(
                children: [
                  Icon(
                    labels[method]!['icon'] as IconData,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(labels[method]!['name'] as String),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: selectedPaymentMethod == method
                      ? AppTheme.primaryColor
                      : AppTheme.borderColor,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
