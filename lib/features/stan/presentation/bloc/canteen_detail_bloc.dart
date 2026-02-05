import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/utils/constants.dart';
import 'package:kantin_app/features/cart/data/services/cart_service.dart';
import 'package:kantin_app/features/menu/domain/usecases/get_menu_by_stan_id_usecase.dart';
import 'package:kantin_app/features/stan/presentation/bloc/canteen_detail_event.dart';
import 'package:kantin_app/features/stan/presentation/bloc/canteen_detail_state.dart';

class CanteenDetailBloc extends Bloc<CanteenDetailEvent, CanteenDetailState> {
  final CartService cartService;
  final GetMenuByStanIdUseCase getMenuByStanIdUseCase;
  late String _stanId;
  late String _stanName;

  CanteenDetailBloc({
    required this.cartService,
    required this.getMenuByStanIdUseCase,
  }) : super(const CanteenDetailInitial()) {
    on<LoadCanteenDetailEvent>(_onLoadCanteenDetail);
    on<AddItemToCartEvent>(_onAddItemToCart);
    on<UpdateItemQuantityEvent>(_onUpdateItemQuantity);
    on<RemoveItemFromCartEvent>(_onRemoveItemFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<RefreshCartEvent>(_onRefreshCart);
    on<SwitchStanEvent>(_onSwitchStan);
  }

  Future<void> _onLoadCanteenDetail(
    LoadCanteenDetailEvent event,
    Emitter<CanteenDetailState> emit,
  ) async {
    emit(const CanteenDetailLoading());

    try {
      _stanId = event.stanId;

      if (!cartService.isInitialized) {
        await cartService.init();
      }

      final menuResult = await getMenuByStanIdUseCase(
        MenuByStanParams(stanId: _stanId),
      );

      final menuItems = menuResult.fold((failure) {
        throw Exception(failure.message);
      }, (items) => items);

      final foodItems = menuItems
          .where((item) => item.jenis == AppConstants.jenisMakanan)
          .toList();
      final beverageItems = menuItems
          .where((item) => item.jenis == AppConstants.jenisMinuman)
          .toList();

      if (foodItems.isNotEmpty) {
        _stanName = foodItems.first.stanName;
      } else if (beverageItems.isNotEmpty) {
        _stanName = beverageItems.first.stanName;
      } else {
        _stanName = '';
      }

      final cartItems = await cartService.getCartItems();
      final Map<String, int> quantities = {};

      for (final item in cartItems) {
        quantities[item.menuId] = item.quantity;
      }

      if (cartItems.isNotEmpty) {
        _stanName = cartItems.first.stanName;
      }

      final totalCount = await cartService.getTotalItemsQuantity();
      final total = await cartService.getCartTotal();

      emit(
        CanteenDetailLoaded(
          foodItems: foodItems,
          beverageItems: beverageItems,
          itemQuantities: quantities,
          totalItemsCount: totalCount,
          cartTotal: total,
          stanName: _stanName,
          stanId: _stanId,
        ),
      );
    } catch (e) {
      emit(
        CanteenDetailError('Failed to load canteen details: ${e.toString()}'),
      );
    }
  }

  Future<void> _onAddItemToCart(
    AddItemToCartEvent event,
    Emitter<CanteenDetailState> emit,
  ) async {
    if (state is! CanteenDetailLoaded) return;

    final currentState = state as CanteenDetailLoaded;

    try {
      // Check if cart has items from different stan
      final cartItems = await cartService.getCartItems();

      if (cartItems.isNotEmpty && cartItems.first.stanId != event.item.stanId) {
        // Emit stan switch confirmation state
        emit(StanSwitchConfirmation(cartItems.first.stanName, event.item));
        // Restore previous loaded state so UI stays interactive
        emit(currentState);
        return;
      }

      // Add item to cart
      await cartService.addToCart(event.item);

      // Refresh cart data
      await _refreshCartData(emit, currentState);
    } catch (e) {
      emit(CanteenDetailError('Failed to add item to cart: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateItemQuantity(
    UpdateItemQuantityEvent event,
    Emitter<CanteenDetailState> emit,
  ) async {
    if (state is! CanteenDetailLoaded) return;

    final currentState = state as CanteenDetailLoaded;

    try {
      await cartService.updateQuantityByMenuId(
        event.item.id,
        event.newQuantity,
      );
      await _refreshCartData(emit, currentState);
    } catch (e) {
      emit(CanteenDetailError('Failed to update quantity: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCartEvent event,
    Emitter<CanteenDetailState> emit,
  ) async {
    if (state is! CanteenDetailLoaded) return;

    final currentState = state as CanteenDetailLoaded;

    try {
      await cartService.updateQuantityByMenuId(event.menuId, 0);
      await _refreshCartData(emit, currentState);
    } catch (e) {
      emit(CanteenDetailError('Failed to remove item: ${e.toString()}'));
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CanteenDetailState> emit,
  ) async {
    if (state is! CanteenDetailLoaded) return;

    final currentState = state as CanteenDetailLoaded;

    try {
      await cartService.clearCart();
      await _refreshCartData(emit, currentState);
    } catch (e) {
      emit(CanteenDetailError('Failed to clear cart: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshCart(
    RefreshCartEvent event,
    Emitter<CanteenDetailState> emit,
  ) async {
    if (state is! CanteenDetailLoaded) return;

    final currentState = state as CanteenDetailLoaded;

    try {
      await _refreshCartData(emit, currentState);
    } catch (e) {
      emit(CanteenDetailError('Failed to refresh cart: ${e.toString()}'));
    }
  }

  Future<void> _onSwitchStan(
    SwitchStanEvent event,
    Emitter<CanteenDetailState> emit,
  ) async {
    if (state is! CanteenDetailLoaded) return;

    final currentState = state as CanteenDetailLoaded;

    try {
      // Clear cart
      await cartService.clearCart();

      // Add new item
      await cartService.addToCart(event.item);

      // Refresh cart data
      await _refreshCartData(emit, currentState);
    } catch (e) {
      emit(CanteenDetailError('Failed to switch stan: ${e.toString()}'));
    }
  }

  Future<void> _refreshCartData(
    Emitter<CanteenDetailState> emit,
    CanteenDetailLoaded currentState,
  ) async {
    final cartItems = await cartService.getCartItems();
    final Map<String, int> quantities = {};

    for (final item in cartItems) {
      quantities[item.menuId] = item.quantity;
    }

    String stanName = _stanName;
    if (cartItems.isNotEmpty) {
      stanName = cartItems.first.stanName;
    }

    final totalCount = await cartService.getTotalItemsQuantity();
    final total = await cartService.getCartTotal();

    emit(
      currentState.copyWith(
        itemQuantities: quantities,
        totalItemsCount: totalCount,
        cartTotal: total,
        stanName: stanName,
      ),
    );
  }
}
