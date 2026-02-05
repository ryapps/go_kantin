import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';

/// Extension methods for Menu entity to handle discount calculations
extension MenuDiskonExtension on Menu {
  /// Calculate final price after applying discount
  double calculateDiscountedPrice(Diskon? diskon) {
    if (diskon == null || !diskon.isValid) {
      return harga;
    }

    final discountAmount = harga * (diskon.persentaseDiskon / 100);
    return harga - discountAmount;
  }

  /// Calculate discount amount
  double calculateDiscountAmount(Diskon? diskon) {
    if (diskon == null || !diskon.isValid) {
      return 0;
    }

    return harga * (diskon.persentaseDiskon / 100);
  }

  /// Check if menu has valid discount
  bool hasValidDiskon(Diskon? diskon) {
    return diskon != null && diskon.isValid;
  }

  /// Get discount percentage text for UI display
  String getDiscountLabel(Diskon? diskon) {
    if (diskon == null || !diskon.isValid) {
      return '';
    }

    return '${diskon.persentaseDiskon.toStringAsFixed(0)}% OFF';
  }

  /// Format price with/without discount for display
  String formatPriceWithDiskon(Diskon? diskon) {
    if (hasValidDiskon(diskon)) {
      final discountedPrice = calculateDiscountedPrice(diskon);
      return 'Rp ${discountedPrice.toStringAsFixed(0)}';
    }
    return 'Rp ${harga.toStringAsFixed(0)}';
  }

  /// Get original price text (for strikethrough when discounted)
  String getOriginalPriceText() {
    return 'Rp ${harga.toStringAsFixed(0)}';
  }
}

/// Helper functions for menu discount calculations
class MenuDiskonHelper {
  /// Calculate total price for multiple menu items with their discounts
  static double calculateTotalPrice(List<MenuDiskonPair> items) {
    return items.fold<double>(
      0,
      (sum, item) => sum + item.menu.calculateDiscountedPrice(item.diskon),
    );
  }

  /// Calculate total discount amount for multiple items
  static double calculateTotalDiscountAmount(List<MenuDiskonPair> items) {
    return items.fold<double>(
      0,
      (sum, item) => sum + item.menu.calculateDiscountAmount(item.diskon),
    );
  }

  /// Group menu items by whether they have discount or not
  static Map<String, List<MenuDiskonPair>> groupByDiscount(
    List<MenuDiskonPair> items,
  ) {
    final withDiscount = <MenuDiskonPair>[];
    final withoutDiscount = <MenuDiskonPair>[];

    for (final item in items) {
      if (item.menu.hasValidDiskon(item.diskon)) {
        withDiscount.add(item);
      } else {
        withoutDiscount.add(item);
      }
    }

    return {'withDiscount': withDiscount, 'withoutDiscount': withoutDiscount};
  }
}

/// Pair of Menu and its associated Diskon
class MenuDiskonPair {
  final Menu menu;
  final Diskon? diskon;
  final int quantity;

  const MenuDiskonPair({required this.menu, this.diskon, this.quantity = 1});

  double get subtotal => menu.calculateDiscountedPrice(diskon) * quantity;
  double get discountAmount => menu.calculateDiscountAmount(diskon) * quantity;
  double get originalPrice => menu.harga * quantity;
}
