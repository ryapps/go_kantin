import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/diskon_model.dart';
import '../models/menu_diskon_model.dart';

/// Remote datasource for discount operations
abstract class DiskonRemoteDatasource {
  /// Create new discount
  Future<DiskonModel> createDiskon({
    required String namaDiskon,
    required double persentaseDiskon,
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
  });

  /// Get all discounts
  Future<List<DiskonModel>> getAllDiskon();

  /// Get active/valid discounts only
  Future<List<DiskonModel>> getActiveDiskon();

  /// Get discount by ID
  Future<DiskonModel> getDiskonById(String diskonId);

  /// Update discount
  Future<DiskonModel> updateDiskon({
    required String diskonId,
    String? namaDiskon,
    double? persentaseDiskon,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  });

  /// Activate discount
  Future<void> activateDiskon(String diskonId);

  /// Deactivate discount
  Future<void> deactivateDiskon(String diskonId);

  /// Delete discount
  Future<void> deleteDiskon(String diskonId);

  // Menu-Diskon junction operations

  /// Link discount to menu items
  Future<void> linkDiskonToMenu({
    required String diskonId,
    required List<String> menuIds,
  });

  /// Unlink discount from menu items
  Future<void> unlinkDiskonFromMenu({
    required String diskonId,
    required List<String> menuIds,
  });

  /// Get menu IDs that have a discount
  Future<List<String>> getMenuIdsWithDiskon(String diskonId);

  /// Get discount for a menu item (if any)
  Future<DiskonModel?> getDiskonForMenu(String menuId);

  /// Get all active discounts for a menu item
  Future<List<DiskonModel>> getActiveDiscountsForMenu(String menuId);
}

class DiskonRemoteDatasourceImpl implements DiskonRemoteDatasource {
  final FirebaseFirestore _firestore;

  DiskonRemoteDatasourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<DiskonModel> createDiskon({
    required String namaDiskon,
    required double persentaseDiskon,
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
  }) async {
    try {
      final collection = _firestore.collection(AppConstants.diskonCollection);
      final docRef = await collection.add({
        'namaDiskon': namaDiskon,
        'persentaseDiskon': persentaseDiskon,
        'tanggalAwal': Timestamp.fromDate(tanggalAwal),
        'tanggalAkhir': Timestamp.fromDate(tanggalAkhir),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final snapshot = await docRef.get();
      return DiskonModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal membuat diskon: ${e.toString()}');
    }
  }

  @override
  Future<List<DiskonModel>> getAllDiskon() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.diskonCollection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(DiskonModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil semua diskon: ${e.toString()}');
    }
  }

  @override
  Future<List<DiskonModel>> getActiveDiskon() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.diskonCollection)
          .where('isActive', isEqualTo: true)
          .get();
      final now = DateTime.now();
      return snapshot.docs
          .map(DiskonModel.fromFirestore)
          .where(
            (model) =>
                model.isActive &&
                now.isAfter(model.tanggalAwal.toDate()) &&
                now.isBefore(model.tanggalAkhir.toDate()),
          )
          .toList();
    } catch (e) {
      throw ServerException('Gagal mengambil diskon aktif: ${e.toString()}');
    }
  }

  @override
  Future<DiskonModel> getDiskonById(String diskonId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.diskonCollection)
          .doc(diskonId)
          .get();
      if (!snapshot.exists) {
        throw ServerException('Diskon tidak ditemukan');
      }
      return DiskonModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal mengambil diskon: ${e.toString()}');
    }
  }

  @override
  Future<DiskonModel> updateDiskon({
    required String diskonId,
    String? namaDiskon,
    double? persentaseDiskon,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (namaDiskon != null) updateData['namaDiskon'] = namaDiskon;
      if (persentaseDiskon != null) {
        updateData['persentaseDiskon'] = persentaseDiskon;
      }
      if (tanggalAwal != null) {
        updateData['tanggalAwal'] = Timestamp.fromDate(tanggalAwal);
      }
      if (tanggalAkhir != null) {
        updateData['tanggalAkhir'] = Timestamp.fromDate(tanggalAkhir);
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(AppConstants.diskonCollection)
            .doc(diskonId)
            .update(updateData);
      }

      final snapshot = await _firestore
          .collection(AppConstants.diskonCollection)
          .doc(diskonId)
          .get();
      if (!snapshot.exists) {
        throw ServerException('Diskon tidak ditemukan');
      }
      return DiskonModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal mengupdate diskon: ${e.toString()}');
    }
  }

  @override
  Future<void> activateDiskon(String diskonId) async {
    try {
      await _firestore
          .collection(AppConstants.diskonCollection)
          .doc(diskonId)
          .update({'isActive': true});
    } catch (e) {
      throw ServerException('Gagal mengaktifkan diskon: ${e.toString()}');
    }
  }

  @override
  Future<void> deactivateDiskon(String diskonId) async {
    try {
      await _firestore
          .collection(AppConstants.diskonCollection)
          .doc(diskonId)
          .update({'isActive': false});
    } catch (e) {
      throw ServerException('Gagal menonaktifkan diskon: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDiskon(String diskonId) async {
    try {
      await _firestore
          .collection(AppConstants.diskonCollection)
          .doc(diskonId)
          .delete();
    } catch (e) {
      throw ServerException('Gagal menghapus diskon: ${e.toString()}');
    }
  }

  @override
  Future<void> linkDiskonToMenu({
    required String diskonId,
    required List<String> menuIds,
  }) async {
    try {
      final collection = _firestore.collection(
        AppConstants.menuDiskonCollection,
      );
      final batch = _firestore.batch();

      for (final menuId in menuIds) {
        final docId = '${menuId}_$diskonId';
        final docRef = collection.doc(docId);
        batch.set(docRef, {'menuId': menuId, 'diskonId': diskonId});
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(
        'Gagal menghubungkan diskon ke menu: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> unlinkDiskonFromMenu({
    required String diskonId,
    required List<String> menuIds,
  }) async {
    try {
      final collection = _firestore.collection(
        AppConstants.menuDiskonCollection,
      );
      final batch = _firestore.batch();

      for (final menuId in menuIds) {
        final docId = '${menuId}_$diskonId';
        batch.delete(collection.doc(docId));
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(
        'Gagal memutus hubungan diskon dari menu: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getMenuIdsWithDiskon(String diskonId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.menuDiskonCollection)
          .where('diskonId', isEqualTo: diskonId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data()['menuId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e) {
      throw ServerException(
        'Gagal mengambil ID menu dengan diskon: ${e.toString()}',
      );
    }
  }

  @override
  Future<DiskonModel?> getDiskonForMenu(String menuId) async {
    try {
      final linkSnapshot = await _firestore
          .collection(AppConstants.menuDiskonCollection)
          .where('menuId', isEqualTo: menuId)
          .get();

      if (linkSnapshot.docs.isEmpty) {
        return null;
      }

      for (final link in linkSnapshot.docs) {
        final menuDiskon = MenuDiskonModel.fromFirestore(link);
        final diskonSnap = await _firestore
            .collection(AppConstants.diskonCollection)
            .doc(menuDiskon.diskonId)
            .get();
        if (diskonSnap.exists) {
          final diskon = DiskonModel.fromFirestore(diskonSnap);
          if (diskon.isValid) {
            return diskon;
          }
        }
      }

      return null;
    } catch (e) {
      throw ServerException(
        'Gagal mengambil diskon untuk menu: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<DiskonModel>> getActiveDiscountsForMenu(String menuId) async {
    try {
      final linkSnapshot = await _firestore
          .collection(AppConstants.menuDiskonCollection)
          .where('menuId', isEqualTo: menuId)
          .get();

      if (linkSnapshot.docs.isEmpty) {
        return [];
      }

      final discounts = <DiskonModel>[];
      for (final link in linkSnapshot.docs) {
        final menuDiskon = MenuDiskonModel.fromFirestore(link);
        final diskonSnap = await _firestore
            .collection(AppConstants.diskonCollection)
            .doc(menuDiskon.diskonId)
            .get();
        if (diskonSnap.exists) {
          final diskon = DiskonModel.fromFirestore(diskonSnap);
          if (diskon.isValid) {
            discounts.add(diskon);
          }
        }
      }

      return discounts;
    } catch (e) {
      throw ServerException(
        'Gagal mengambil diskon aktif untuk menu: ${e.toString()}',
      );
    }
  }
}
