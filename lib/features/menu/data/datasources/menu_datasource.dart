import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/menu_model.dart';

/// Remote datasource for menu operations
abstract class MenuRemoteDatasource {
  /// Create new menu item
  Future<MenuModel> createMenu({
    required String stanId,
    required String namaMakanan,
    required double harga,
    required String jenis,
    required String fotoPath, // Local file path to upload
    required String deskripsi,
  });

  /// Get all menu items
  Future<List<MenuModel>> getAllMenu();

  /// Get menu items by stan ID
  Future<List<MenuModel>> getMenuByStanId(String stanId);

  /// Get menu item by ID
  Future<MenuModel> getMenuById(String menuId);

  /// Search menu items by name
  Future<List<MenuModel>> searchMenu(String query);

  /// Filter menu by type (makanan/minuman)
  Future<List<MenuModel>> filterMenuByType(String jenis);

  /// Update menu item
  Future<MenuModel> updateMenu({
    required String menuId,
    String? namaMakanan,
    double? harga,
    String? jenis,
    String? fotoPath, // Optional: new photo path
    String? deskripsi,
  });

  /// Toggle menu availability
  Future<void> toggleAvailability(
    String menuId,
    bool isAvailable,
  );

  /// Delete menu item
  Future<void> deleteMenu(String menuId);

  /// Stream of menu items (for real-time updates)
  Stream<List<MenuModel>> watchAllMenu();

  /// Stream of menu items by stan ID
  Stream<List<MenuModel>> watchMenuByStanId(String stanId);
}

class MenuRemoteDatasourceImpl implements MenuRemoteDatasource {
  final FirebaseFirestore _firestore;

  MenuRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<MenuModel> createMenu({
    required String stanId,
    required String namaMakanan,
    required double harga,
    required String jenis,
    required String fotoPath,
    required String deskripsi,
  }) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal membuat menu: ${e.toString()}');
    }
  }

  @override
  Future<List<MenuModel>> getAllMenu() async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal mengambil semua menu: ${e.toString()}');
    }
  }

  @override
  Future<List<MenuModel>> getMenuByStanId(String stanId) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal mengambil menu berdasarkan stan: ${e.toString()}');
    }
  }

  @override
  Future<MenuModel> getMenuById(String menuId) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal mengambil menu: ${e.toString()}');
    }
  }

  @override
  Future<List<MenuModel>> searchMenu(String query) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal mencari menu: ${e.toString()}');
    }
  }

  @override
  Future<List<MenuModel>> filterMenuByType(String jenis) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal memfilter menu: ${e.toString()}');
    }
  }

  @override
  Future<MenuModel> updateMenu({
    required String menuId,
    String? namaMakanan,
    double? harga,
    String? jenis,
    String? fotoPath,
    String? deskripsi,
  }) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal mengupdate menu: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleAvailability(
    String menuId,
    bool isAvailable,
  ) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal mengganti ketersediaan menu: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMenu(String menuId) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal menghapus menu: ${e.toString()}');
    }
  }

  @override
  Stream<List<MenuModel>> watchAllMenu() {
    // Implementation will go here
    throw UnimplementedError();
  }

  @override
  Stream<List<MenuModel>> watchMenuByStanId(String stanId) {
    // Implementation will go here
    throw UnimplementedError();
  }
}