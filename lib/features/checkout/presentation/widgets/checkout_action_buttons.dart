import 'package:flutter/material.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';

class CheckoutActionButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const CheckoutActionButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: PrimaryButton(
        text: 'Pesan Sekarang',
        
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

class CheckoutProcessingButton extends StatelessWidget {
  const CheckoutProcessingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: PrimaryButton(
        text: 'Memproses...',
        onPressed: null,
        isLoading: true,
      ),
    );
  }
}

class CheckoutRetryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CheckoutRetryButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: PrimaryButton(text: 'Retry', onPressed: onPressed),
    );
  }
}
