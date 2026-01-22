import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository.dart';

/// Helper class untuk menghitung diskon pada checkout
class CheckoutDiscountHelper {
  final IDiskonRepository _diskonRepository;

  CheckoutDiscountHelper({required IDiskonRepository diskonRepository})
    : _diskonRepository = diskonRepository;

  /// Ambil diskon untuk item tertentu
  Future<double> getDiskonPercentageForItem(String menuId) async {
    try {
      final result = await _diskonRepository.getDiskonForMenu(menuId);

      return result.fold(
        (failure) => 0.0, // Jika ada error, return 0%
        (diskon) {
          if (diskon != null && diskon.isValid) {
            return diskon.persentaseDiskon;
          }
          return 0.0;
        },
      );
    } catch (e) {
      return 0.0;
    }
  }

  /// Ambil semua diskon aktif untuk item
  Future<List<double>> getActiveDiscountsForItem(String menuId) async {
    try {
      final result = await _diskonRepository.getActiveDiscountsForMenu(menuId);

      return result.fold(
        (failure) => [],
        (diskons) => diskons
            .where((d) => d.isValid)
            .map((d) => d.persentaseDiskon)
            .toList(),
      );
    } catch (e) {
      return [];
    }
  }

  /// Hitung total diskon untuk sebuah item
  /// Jika ada multiple diskon, ambil yang terbesar
  Future<double> calculateItemDiscount({
    required String menuId,
    required double itemPrice,
    required int quantity,
  }) async {
    try {
      final diskons = await getActiveDiscountsForItem(menuId);

      if (diskons.isEmpty) return 0.0;

      // Ambil diskon terbesar
      final maxDiskon = diskons.reduce((a, b) => a > b ? a : b);
      final totalPrice = itemPrice * quantity;
      final diskonAmount = (totalPrice * maxDiskon) / 100;

      return diskonAmount;
    } catch (e) {
      return 0.0;
    }
  }

  /// Hitung total diskon untuk semua items di keranjang
  Future<double> calculateTotalDiscount(List<CartItemWithPrice> items) async {
    double totalDiskon = 0.0;

    for (final item in items) {
      final diskonAmount = await calculateItemDiscount(
        menuId: item.menuId,
        itemPrice: item.price,
        quantity: item.quantity,
      );
      totalDiskon += diskonAmount;
    }

    return totalDiskon;
  }

  /// Get discount info untuk sebuah item (untuk display)
  Future<DiscountInfo?> getDiscountInfo(String menuId) async {
    try {
      final result = await _diskonRepository.getDiskonForMenu(menuId);

      return result.fold((failure) => null, (diskon) {
        if (diskon != null && diskon.isValid) {
          return DiscountInfo(
            name: diskon.namaDiskon,
            percentage: diskon.persentaseDiskon,
            startDate: diskon.tanggalAwal,
            endDate: diskon.tanggalAkhir,
          );
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }
}

/// Model untuk informasi diskon
class DiscountInfo {
  final String name;
  final double percentage;
  final DateTime startDate;
  final DateTime endDate;

  DiscountInfo({
    required this.name,
    required this.percentage,
    required this.startDate,
    required this.endDate,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  String get daysRemaining {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    if (difference <= 0) return 'Expired';
    return '$difference hari';
  }
}

/// Model untuk item dengan harga untuk perhitungan diskon
class CartItemWithPrice {
  final String menuId;
  final double price;
  final int quantity;

  CartItemWithPrice({
    required this.menuId,
    required this.price,
    required this.quantity,
  });
}
