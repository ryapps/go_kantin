import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:kantin_app/features/checkout/presentation/widgets/checkout_action_buttons.dart';
import 'package:kantin_app/features/checkout/presentation/widgets/checkout_discount_section.dart';
import 'package:kantin_app/features/checkout/presentation/widgets/checkout_notes_section.dart';
import 'package:kantin_app/features/checkout/presentation/widgets/checkout_order_section.dart';
import 'package:kantin_app/features/checkout/presentation/widgets/checkout_order_summary.dart';
import 'package:kantin_app/features/checkout/presentation/widgets/checkout_payment_method_section.dart';
import 'package:kantin_app/features/checkout/presentation/widgets/checkout_stan_info.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger load checkout event
    context.read<CheckoutBloc>().add(const LoadCheckoutEvent());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Checkout', style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppTheme.backgroundColor,
        leading: BackButton(color: AppTheme.textPrimary),
      ),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                context.go('/order-tracking/${state.transaksiId}');
              }
            });
          } else if (state is CheckoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CheckoutLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CheckoutEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang Kosong',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          if (state is CheckoutError) {
            print(state.message);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  CheckoutRetryButton(
                    onPressed: () {
                      context.read<CheckoutBloc>().add(
                        const LoadCheckoutEvent(),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          if (state is CheckoutLoaded) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutStanInfo(stanName: state.stanName),
                      const SizedBox(height: 24),
                      CheckoutOrderSection(
                        cartItems: state.cartItems,
                        itemDiscounts: state.itemDiscounts,
                      ),
                      const SizedBox(height: 24),
                      CheckoutDiscountSection(
                        cartItems: state.cartItems,
                        menuDiscounts: state.menuDiscounts,
                        enabledMenuDiscounts: state.enabledMenuDiscounts,
                        onToggleDiscount: (menuId, enabled) {
                          context.read<CheckoutBloc>().add(
                            ToggleMenuDiscountEvent(
                              menuId: menuId,
                              enabled: enabled,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      CheckoutOrderSummary(
                        subtotal: state.subtotal,
                        totalDiscount: state.totalDiscount,
                        finalTotal: state.finalTotal,
                      ),
                      const SizedBox(height: 24),
                      CheckoutPaymentMethodSection(
                        selectedPaymentMethod: state.selectedPaymentMethod,
                        onSelected: (method) {
                          context.read<CheckoutBloc>().add(
                            SelectPaymentMethodEvent(method),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      CheckoutNotesSection(
                        controller: _notesController,
                        onChanged: (value) {
                          context.read<CheckoutBloc>().add(
                            UpdateNotesEvent(value),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                if (state is! CheckoutProcessing)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: CheckoutActionButton(
                      enabled: state.selectedPaymentMethod != null,
                      onPressed: () {
                        context.read<CheckoutBloc>().add(
                          const ProcessCheckoutEvent(),
                        );
                      },
                    ),
                  ),
                if (state is CheckoutProcessing)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: const CheckoutProcessingButton(),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Section widgets extracted to separate files.
}
