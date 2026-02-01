import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
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
  Future<void> toggleAvailability(String menuId, bool isAvailable);

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
      final stanDoc = await _firestore
          .collection(AppConstants.stanCollection)
          .doc(stanId)
          .get();

      if (!stanDoc.exists) {
        throw ServerException('Stan tidak ditemukan untuk ID: $stanId');
      }

      final stanName = stanDoc.data()?['namaStan'];
      if (stanName == null || stanName.toString().trim().isEmpty) {
        throw ServerException('Nama stan tidak valid untuk ID: $stanId');
      }

      final collection = _firestore.collection(AppConstants.menuCollection);
      final docRef = await collection.add({
        'stanId': stanId,
        'stanName': stanName,
        'namaItem': namaMakanan,
        'harga': harga,
        'jenis': jenis,
        'foto': fotoPath,
        'deskripsi': deskripsi,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await docRef.get();
      return MenuModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal membuat menu: ${e.toString()}');
    }
  }

  @override
  Future<List<MenuModel>> getAllMenu() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.menuCollection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(MenuModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil semua menu: ${e.toString()}');
    }
  }

  @override
  Future<List<MenuModel>> getMenuByStanId(String stanId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.menuCollection)
          .where('stanId', isEqualTo: stanId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(MenuModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException(
        'Gagal mengambil menu berdasarkan stan: ${e.toString()}',
      );
    }
  }

  @override
  Future<MenuModel> getMenuById(String menuId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.menuCollection)
          .doc(menuId)
          .get();
      if (!snapshot.exists) {
        throw ServerException('Menu tidak ditemukan');
      }
      return MenuModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal mengambil menu: ${e.toString()}');
    }
  }

  @override
  Future<List<MenuModel>> searchMenu(String query) async {
    try {
      final keyword = query.trim();
      if (keyword.isEmpty) {
        return getAllMenu();
      }

      final snapshot = await _firestore
          .collection(AppConstants.menuCollection)
          .where('namaItem', isGreaterThanOrEqualTo: keyword)
          .where('namaItem', isLessThan: '${keyword}\uf8ff')
          .get();
      return snapshot.docs.map(MenuModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Gagal mencari menu: ${e.toString()}');
    }
  }

  @override
  Future<List<MenuModel>> filterMenuByType(String jenis) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.menuCollection)
          .where('jenis', isEqualTo: jenis)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(MenuModel.fromFirestore).toList();
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
      // Get the current menu to retrieve the stanId
      final menuSnapshot = await _firestore
          .collection(AppConstants.menuCollection)
          .doc(menuId)
          .get();

      if (!menuSnapshot.exists) {
        throw ServerException('Menu tidak ditemukan');
      }

      final menuData = menuSnapshot.data()!;
      final stanId = menuData['stanId'] as String;

      // Get the current stanName to ensure it's still valid
      final stanDoc = await _firestore
          .collection(AppConstants.stanCollection)
          .doc(stanId)
          .get();

      if (!stanDoc.exists) {
        throw ServerException('Stan tidak ditemukan untuk ID: $stanId');
      }

      final stanName = stanDoc.data()?['namaStan'];
      if (stanName == null || stanName.toString().trim().isEmpty) {
        throw ServerException('Nama stan tidak valid untuk ID: $stanId');
      }

      final updateData = <String, dynamic>{};
      if (namaMakanan != null) updateData['namaItem'] = namaMakanan;
      if (harga != null) updateData['harga'] = harga;
      if (jenis != null) updateData['jenis'] = jenis;
      if (fotoPath != null) updateData['foto'] = fotoPath;
      if (deskripsi != null) updateData['deskripsi'] = deskripsi;
      // Always update the stanName to ensure it's current
      updateData['stanName'] = stanName;

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(AppConstants.menuCollection)
            .doc(menuId)
            .update(updateData);
      }

      final snapshot = await _firestore
          .collection(AppConstants.menuCollection)
          .doc(menuId)
          .get();
      if (!snapshot.exists) {
        throw ServerException('Menu tidak ditemukan');
      }
      return MenuModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal mengupdate menu: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleAvailability(String menuId, bool isAvailable) async {
    try {
      await _firestore
          .collection(AppConstants.menuCollection)
          .doc(menuId)
          .update({'isAvailable': isAvailable});
    } catch (e) {
      throw ServerException(
        'Gagal mengganti ketersediaan menu: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteMenu(String menuId) async {
    try {
      await _firestore
          .collection(AppConstants.menuCollection)
          .doc(menuId)
          .delete();
    } catch (e) {
      throw ServerException('Gagal menghapus menu: ${e.toString()}');
    }
  }

  @override
  Stream<List<MenuModel>> watchAllMenu() {
    return _firestore
        .collection(AppConstants.menuCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MenuModel.fromFirestore).toList());
  }

  @override
  Stream<List<MenuModel>> watchMenuByStanId(String stanId) {
    return _firestore
        .collection(AppConstants.menuCollection)
        .where('stanId', isEqualTo: stanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MenuModel.fromFirestore).toList());
  }
}
