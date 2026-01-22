import 'package:hive_flutter/hive_flutter.dart';
import 'package:kantin_app/features/cart/domain/entities/cart_item.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';
import 'package:uuid/uuid.dart';

class CartService {
  static const String cartBoxName = 'cart_items';
  late Box<Map> _cartBox;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize Hive box
  Future<void> init() async {
    if (!_isInitialized) {
      _cartBox = await Hive.openBox<Map>(cartBoxName);
      _isInitialized = true;
    }
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'CartService has not been initialized. Call init() first.',
      );
    }
  }

  // Add item to cart
  Future<void> addToCart(Menu menu, {int quantity = 1}) async {
    _checkInitialized();
    final cartItem = CartItem(
      id: const Uuid().v4(),
      menuId: menu.id,
      stanId: menu.stanId,
      stanName: menu.stanName,
      namaItem: menu.namaItem,
      harga: menu.harga,
      foto: menu.foto,
      quantity: quantity,
      addedAt: DateTime.now(),
    );

    // Check if same menu from same stan already exists
    final existingKey = _findCartItemKey(menu.id);

    if (existingKey != null) {
      // Update quantity if item already exists - ADD 1 (for increment from button)
      final existingItem = CartItem.fromMap(
        Map<String, dynamic>.from(_cartBox.getAt(existingKey) as Map),
      );
      await _cartBox.putAt(
        existingKey,
        cartItem.copyWith(quantity: existingItem.quantity + 1).toMap(),
      );
    } else {
      // Add new item
      await _cartBox.add(cartItem.toMap());
    }
  }

  // Get all cart items
  Future<List<CartItem>> getCartItems() async {
    _checkInitialized();
    final items = <CartItem>[];
    for (int i = 0; i < _cartBox.length; i++) {
      final itemMap = _cartBox.getAt(i);
      if (itemMap != null) {
        items.add(CartItem.fromMap(Map<String, dynamic>.from(itemMap)));
      }
    }
    return items;
  }

  // Get cart items count (unique items)
  Future<int> getCartItemsCount() async {
    _checkInitialized();
    return _cartBox.length;
  }

  // Get total items quantity (sum of all quantities)
  Future<int> getTotalItemsQuantity() async {
    _checkInitialized();
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // Update item quantity by menu ID (replaces quantity instead of adding)
  Future<void> updateQuantityByMenuId(String menuId, int newQuantity) async {
    _checkInitialized();
    final index = _findCartItemKey(menuId);
    if (index != null) {
      final itemMap = _cartBox.getAt(index);
      if (itemMap != null) {
        final item = CartItem.fromMap(Map<String, dynamic>.from(itemMap));
        if (newQuantity > 0) {
          await _cartBox.putAt(
            index,
            item.copyWith(quantity: newQuantity).toMap(),
          );
        } else {
          await _cartBox.deleteAt(index);
        }
      }
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    _checkInitialized();
    final index = _findCartItemKeyByCartId(cartItemId);
    if (index != null && quantity > 0) {
      final itemMap = _cartBox.getAt(index);
      if (itemMap != null) {
        final item = CartItem.fromMap(Map<String, dynamic>.from(itemMap));
        await _cartBox.putAt(index, item.copyWith(quantity: quantity).toMap());
      }
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    _checkInitialized();
    final index = _findCartItemKeyByCartId(cartItemId);
    if (index != null) {
      await _cartBox.deleteAt(index);
    }
  }

  // Clear all cart items
  Future<void> clearCart() async {
    _checkInitialized();
    await _cartBox.clear();
  }

  // Get cart total price
  Future<double> getCartTotal() async {
    _checkInitialized();
    final items = await getCartItems();
    return items.fold<double>(
      0.0,
      (sum, item) => sum + (item.harga * item.quantity),
    );
  }

  // Get items by stan
  Future<List<CartItem>> getCartItemsByStanId(String stanId) async {
    final items = await getCartItems();
    return items.where((item) => item.stanId == stanId).toList();
  }

  // Get unique stans in cart
  Future<List<String>> getStansInCart() async {
    final items = await getCartItems();
    final stanIds = <String>{};
    for (var item in items) {
      stanIds.add(item.stanId);
    }
    return stanIds.toList();
  }

  // Helper method to find cart item by menu ID
  int? _findCartItemKey(String menuId) {
    for (int i = 0; i < _cartBox.length; i++) {
      final itemMap = _cartBox.getAt(i);
      if (itemMap != null) {
        final item = CartItem.fromMap(Map<String, dynamic>.from(itemMap));
        if (item.menuId == menuId) {
          return i;
        }
      }
    }
    return null;
  }

  // Helper method to find cart item by cart item ID
  int? _findCartItemKeyByCartId(String cartItemId) {
    for (int i = 0; i < _cartBox.length; i++) {
      final itemMap = _cartBox.getAt(i);
      if (itemMap != null) {
        final item = CartItem.fromMap(Map<String, dynamic>.from(itemMap));
        if (item.id == cartItemId) {
          return i;
        }
      }
    }
    return null;
  }
}
