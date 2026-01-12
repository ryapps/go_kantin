import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/menu.dart';

/// Menu repository interface
abstract class IMenuRepository {
  /// Create new menu item
  Future<Either<Failure, Menu>> createMenu({
    required String stanId,
    required String namaMakanan,
    required double harga,
    required String jenis,
    required String fotoPath, // Local file path to upload
    required String deskripsi,
  });

  /// Get all menu items
  Future<Either<Failure, List<Menu>>> getAllMenu();

  /// Get menu items by stan ID
  Future<Either<Failure, List<Menu>>> getMenuByStanId(String stanId);

  /// Get menu item by ID
  Future<Either<Failure, Menu>> getMenuById(String menuId);

  /// Search menu items by name
  Future<Either<Failure, List<Menu>>> searchMenu(String query);

  /// Filter menu by type (makanan/minuman)
  Future<Either<Failure, List<Menu>>> filterMenuByType(String jenis);

  /// Update menu item
  Future<Either<Failure, Menu>> updateMenu({
    required String menuId,
    String? namaMakanan,
    double? harga,
    String? jenis,
    String? fotoPath, // Optional: new photo path
    String? deskripsi,
  });

  /// Toggle menu availability
  Future<Either<Failure, void>> toggleAvailability(
    String menuId,
    bool isAvailable,
  );

  /// Delete menu item
  Future<Either<Failure, void>> deleteMenu(String menuId);

  /// Stream of menu items (for real-time updates)
  Stream<Either<Failure, List<Menu>>> watchAllMenu();

  /// Stream of menu items by stan ID
  Stream<Either<Failure, List<Menu>>> watchMenuByStanId(String stanId);

  // Cache operations
  
  /// Get cached menu
  Future<Either<Failure, List<Menu>>> getCachedMenu();

  /// Cache menu locally
  Future<Either<Failure, void>> cacheMenu(List<Menu> menus);

  /// Check if cache is valid
  Future<bool> isCacheValid();
}