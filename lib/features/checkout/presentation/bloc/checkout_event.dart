part of 'checkout_bloc.dart';

/// Basis class untuk semua Checkout events
abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk load checkout data
class LoadCheckoutEvent extends CheckoutEvent {
  const LoadCheckoutEvent();
}

/// Event untuk refresh cart items
class RefreshCartEvent extends CheckoutEvent {
  const RefreshCartEvent();
}

/// Event untuk select payment method
class SelectPaymentMethodEvent extends CheckoutEvent {
  final String paymentMethod;

  const SelectPaymentMethodEvent(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

/// Event untuk update notes
class UpdateNotesEvent extends CheckoutEvent {
  final String notes;

  const UpdateNotesEvent(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Event untuk toggle diskon per menu
class ToggleMenuDiscountEvent extends CheckoutEvent {
  final String menuId;
  final bool enabled;

  const ToggleMenuDiscountEvent({required this.menuId, required this.enabled});

  @override
  List<Object?> get props => [menuId, enabled];
}

/// Event untuk process checkout
class ProcessCheckoutEvent extends CheckoutEvent {
  const ProcessCheckoutEvent();
}

/// Event untuk clear checkout (after success)
class ClearCheckoutEvent extends CheckoutEvent {
  const ClearCheckoutEvent();
}
