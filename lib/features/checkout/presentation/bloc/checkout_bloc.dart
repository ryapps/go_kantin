import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/cart/data/services/cart_service.dart';
import 'package:kantin_app/features/cart/domain/entities/cart_item.dart';
import 'package:kantin_app/features/diskon/domain/entities/menu_diskon.dart';
import 'package:kantin_app/features/diskon/domain/usecases/get_diskon_for_menu_usecase.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';
import 'package:kantin_app/features/transaksi/domain/repositories/i_transaksi_repository.dart';
import 'package:uuid/uuid.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CartService cartService;
  final GetDiskonForMenuUseCase getDiskonForMenuUseCase;
  final ITransaksiRepository transaksiRepository;
  final firebase_auth.FirebaseAuth firebaseAuth;
  final Uuid _uuid = const Uuid();

  CheckoutBloc({
    required this.cartService,
    required this.getDiskonForMenuUseCase,
    required this.transaksiRepository,
    required this.firebaseAuth,
  }) : super(const CheckoutInitial()) {
    // Register event handlers
    on<LoadCheckoutEvent>(_onLoadCheckout);
    on<RefreshCartEvent>(_onRefreshCart);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<UpdateNotesEvent>(_onUpdateNotes);
    on<ToggleMenuDiscountEvent>(_onToggleMenuDiscount);
    on<ProcessCheckoutEvent>(_onProcessCheckout);
    on<ClearCheckoutEvent>(_onClearCheckout);
  }

  /// Handle LoadCheckoutEvent
  Future<void> _onLoadCheckout(
    LoadCheckoutEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    try {
      emit(const CheckoutLoading());

      // Initialize cart service if not already initialized
      if (!cartService.isInitialized) {
        await cartService.init();
      }

      // Get cart data
      final items = await cartService.getCartItems();
      final subtotal = await cartService.getCartTotal();

      // Check if cart is empty
      if (items.isEmpty) {
        emit(const CheckoutEmpty());
        return;
      }

      final perMenuDiscounts = await _getBestDiscountsPerMenu(items);
      final enabledMenuDiscounts = <String>{};

      final calculation = _recalculateTotals(
        items: items,
        subtotal: subtotal,
        perMenuDiscounts: perMenuDiscounts,
        enabledMenuDiscounts: enabledMenuDiscounts,
      );
      final stanName = items.isNotEmpty ? items.first.stanName : '';

      emit(
        CheckoutLoaded(
          cartItems: items,
          subtotal: subtotal,
          totalDiscount: calculation.totalDiscount,
          finalTotal: calculation.finalTotal,
          stanName: stanName,
          itemDiscounts: calculation.itemDiscounts,
          menuDiscounts: perMenuDiscounts,
          enabledMenuDiscounts: enabledMenuDiscounts,
        ),
      );
    } catch (e) {
      emit(CheckoutError('Failed to load checkout: ${e.toString()}'));
    }
  }

  /// Handle RefreshCartEvent
  Future<void> _onRefreshCart(
    RefreshCartEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) {
      add(const LoadCheckoutEvent());
      return;
    }

    try {
      emit(const CheckoutLoading());

      // Get updated cart data
      final items = await cartService.getCartItems();
      final subtotal = await cartService.getCartTotal();

      if (items.isEmpty) {
        emit(const CheckoutEmpty());
        return;
      }

      final currentState = state as CheckoutLoaded;
      final perMenuDiscounts = await _getBestDiscountsPerMenu(items);
      final enabledMenuDiscounts = currentState.enabledMenuDiscounts
          .where(perMenuDiscounts.containsKey)
          .toSet();
      final calculation = _recalculateTotals(
        items: items,
        subtotal: subtotal,
        perMenuDiscounts: perMenuDiscounts,
        enabledMenuDiscounts: enabledMenuDiscounts,
      );
      final stanName = items.isNotEmpty ? items.first.stanName : '';

      emit(
        currentState.copyWith(
          cartItems: items,
          subtotal: subtotal,
          totalDiscount: calculation.totalDiscount,
          finalTotal: calculation.finalTotal,
          stanName: stanName,
          itemDiscounts: calculation.itemDiscounts,
          menuDiscounts: perMenuDiscounts,
          enabledMenuDiscounts: enabledMenuDiscounts,
        ),
      );
    } catch (e) {
      emit(CheckoutError('Failed to refresh cart: ${e.toString()}'));
    }
  }

  /// Handle SelectPaymentMethodEvent
  Future<void> _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;
    emit(currentState.copyWith(selectedPaymentMethod: event.paymentMethod));
  }

  /// Handle UpdateNotesEvent
  Future<void> _onUpdateNotes(
    UpdateNotesEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;
    emit(currentState.copyWith(notes: event.notes));
  }

  Future<void> _onToggleMenuDiscount(
    ToggleMenuDiscountEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final currentState = state as CheckoutLoaded;
    final updatedEnabled = currentState.enabledMenuDiscounts.toSet();
    if (event.enabled) {
      updatedEnabled.add(event.menuId);
    } else {
      updatedEnabled.remove(event.menuId);
    }

    final calculation = _recalculateTotals(
      items: currentState.cartItems,
      subtotal: currentState.subtotal,
      perMenuDiscounts: currentState.menuDiscounts,
      enabledMenuDiscounts: updatedEnabled,
    );

    emit(
      currentState.copyWith(
        enabledMenuDiscounts: updatedEnabled,
        itemDiscounts: calculation.itemDiscounts,
        totalDiscount: calculation.totalDiscount,
        finalTotal: calculation.finalTotal,
      ),
    );
  }

  /// Handle ProcessCheckoutEvent
  Future<void> _onProcessCheckout(
    ProcessCheckoutEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    try {
      final currentState = state as CheckoutLoaded;

      emit(const CheckoutProcessing());

      // Validate payment method
      if (currentState.selectedPaymentMethod == null) {
        emit(CheckoutError('Please select a payment method'));
        emit(currentState);
        return;
      }

      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        emit(CheckoutError('Silakan login terlebih dahulu'));
        emit(currentState);
        return;
      }

      final stanId = currentState.cartItems.first.stanId;
      final detailItems = _buildDetailItems(
        cartItems: currentState.cartItems,
        itemDiscounts: currentState.itemDiscounts,
      );

      final result = await transaksiRepository.placeOrder(
        siswaId: currentUser.uid,
        stanId: stanId,
        items: detailItems,
      );

      await result.fold(
        (failure) async {
          emit(CheckoutError(failure.message));
          emit(currentState);
        },
        (transaksi) async {
          await cartService.clearCart();
          emit(
            CheckoutSuccess(
              message: 'Pesanan berhasil dibuat',
              transaksiId: transaksi.id,
            ),
          );
        },
      );
    } catch (e) {
      emit(CheckoutError('Failed to process checkout: ${e.toString()}'));
    }
  }

  /// Handle ClearCheckoutEvent
  Future<void> _onClearCheckout(
    ClearCheckoutEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    try {
      await cartService.clearCart();
      emit(const CheckoutEmpty());
    } catch (e) {
      emit(CheckoutError('Failed to clear checkout: ${e.toString()}'));
    }
  }

  _CheckoutDiscountCalculation _recalculateTotals({
    required List<CartItem> items,
    required double subtotal,
    required Map<String, Diskon> perMenuDiscounts,
    required Set<String> enabledMenuDiscounts,
  }) {
    final itemDiscounts = <String, double>{};
    double totalDiscount = 0.0;

    for (final item in items) {
      final discount = perMenuDiscounts[item.menuId];
      final discountAmount =
          discount == null || !enabledMenuDiscounts.contains(item.menuId)
          ? 0.0
          : (item.harga * item.quantity * discount.persentaseDiskon) / 100;
      itemDiscounts[item.menuId] = discountAmount;
      totalDiscount += discountAmount;
    }

    return _CheckoutDiscountCalculation(
      itemDiscounts: itemDiscounts,
      totalDiscount: totalDiscount,
      finalTotal: subtotal - totalDiscount,
    );
  }

  Future<Map<String, Diskon>> _getBestDiscountsPerMenu(
    List<CartItem> items,
  ) async {
    final resultMap = <String, Diskon>{};
    final processedMenuIds = <String>{};

    for (final item in items) {
      if (processedMenuIds.contains(item.menuId)) continue;
      processedMenuIds.add(item.menuId);

      final result = await getDiskonForMenuUseCase(
        MenuDiscountParams(menuId: item.menuId),
      );

      final discount = result.fold((_) => null, (diskon) => diskon);
      if (discount == null || !discount.isValid) continue;
      resultMap[item.menuId] = discount;
    }

    return resultMap;
  }

  List<DetailTransaksi> _buildDetailItems({
    required List<CartItem> cartItems,
    required Map<String, double> itemDiscounts,
  }) {
    return cartItems.map((item) {
      final discount = itemDiscounts[item.menuId] ?? 0;
      return DetailTransaksi(
        id: _uuid.v4(),
        transaksiId: '',
        menuId: item.menuId,
        namaMakanan: item.namaItem,
        hargaBeli: item.harga,
        qty: item.quantity,
        discountAmount: discount,
        subtotal: (item.harga * item.quantity) - discount,
      );
    }).toList();
  }
}

class _CheckoutDiscountCalculation {
  final Map<String, double> itemDiscounts;
  final double totalDiscount;
  final double finalTotal;

  const _CheckoutDiscountCalculation({
    required this.itemDiscounts,
    required this.totalDiscount,
    required this.finalTotal,
  });
}
