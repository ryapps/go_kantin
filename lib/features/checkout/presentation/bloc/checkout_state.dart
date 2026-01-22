part of 'checkout_bloc.dart';

/// Basis class untuk semua Checkout states
abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

/// Loading state saat fetch data
class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

/// Loaded state dengan data checkout berhasil dimuat
class CheckoutLoaded extends CheckoutState {
  final List<CartItem> cartItems;
  final double subtotal;
  final double totalDiscount;
  final double finalTotal;
  final String stanName;
  final Map<String, double> itemDiscounts;
  final Map<String, Diskon> menuDiscounts;
  final Set<String> enabledMenuDiscounts;
  final String? selectedPaymentMethod;
  final String notes;

  const CheckoutLoaded({
    required this.cartItems,
    required this.subtotal,
    required this.totalDiscount,
    required this.finalTotal,
    required this.stanName,
    required this.itemDiscounts,
    required this.menuDiscounts,
    required this.enabledMenuDiscounts,
    this.selectedPaymentMethod,
    this.notes = '',
  });

  /// Copy with untuk update state
  CheckoutLoaded copyWith({
    List<CartItem>? cartItems,
    double? subtotal,
    double? totalDiscount,
    double? finalTotal,
    String? stanName,
    Map<String, double>? itemDiscounts,
    Map<String, Diskon>? menuDiscounts,
    Set<String>? enabledMenuDiscounts,
    String? selectedPaymentMethod,
    String? notes,
  }) {
    return CheckoutLoaded(
      cartItems: cartItems ?? this.cartItems,
      subtotal: subtotal ?? this.subtotal,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      finalTotal: finalTotal ?? this.finalTotal,
      stanName: stanName ?? this.stanName,
      itemDiscounts: itemDiscounts ?? this.itemDiscounts,
      menuDiscounts: menuDiscounts ?? this.menuDiscounts,
      enabledMenuDiscounts: enabledMenuDiscounts ?? this.enabledMenuDiscounts,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    cartItems,
    subtotal,
    totalDiscount,
    finalTotal,
    stanName,
    itemDiscounts,
    menuDiscounts,
    enabledMenuDiscounts,
    selectedPaymentMethod,
    notes,
  ];
}

/// Processing state saat checkout sedang diproses
class CheckoutProcessing extends CheckoutState {
  const CheckoutProcessing();
}

/// Success state setelah checkout berhasil
class CheckoutSuccess extends CheckoutState {
  final String message;
  final String transaksiId;

  const CheckoutSuccess({required this.message, required this.transaksiId});

  @override
  List<Object?> get props => [message, transaksiId];
}

/// Error state
class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty cart state
class CheckoutEmpty extends CheckoutState {
  const CheckoutEmpty();
}
