import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/diskon_model.dart';
import '../models/menu_diskon_model.dart';

/// Remote datasource for discount operations
abstract class DiskonRemoteDatasource {
  /// Create new discount for specific canteen
  Future<DiskonModel> createDiskon({
    required String stanId,
    required String namaDiskon,
    required double persentaseDiskon,
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
  });

  /// Get all discounts for specific canteen
  Future<List<DiskonModel>> getDiskonsByStan(
    String stanId, {
    bool activeOnly = false,
  });

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
    required String stanId,
    required String namaDiskon,
    required double persentaseDiskon,
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
  }) async {
    try {
      final collection = _firestore.collection(AppConstants.diskonCollection);
      final docRef = await collection.add({
        'stanId': stanId,
        'namaDiskon': namaDiskon,
        'persentaseDiskon': persentaseDiskon,
        'tanggalAwal': Timestamp.fromDate(tanggalAwal),
        'tanggalAkhir': Timestamp.fromDate(tanggalAkhir),
        'createdAt': FieldValue.serverTimestamp(),
      });
      final snapshot = await docRef.get();
      return DiskonModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal membuat diskon: ${e.toString()}');
    }
  }

  @override
  Future<List<DiskonModel>> getDiskonsByStan(
    String stanId, {
    bool activeOnly = false,
  }) async {
    try {
      var query = _firestore
          .collection(AppConstants.diskonCollection)
          .where('stanId', isEqualTo: stanId)
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      final diskons = snapshot.docs.map(DiskonModel.fromFirestore).toList();

      if (activeOnly) {
        final now = DateTime.now();
        return diskons
            .where(
              (d) =>
                  now.isAfter(d.tanggalAwal.toDate()) &&
                  now.isBefore(d.tanggalAkhir.toDate()),
            )
            .toList();
      }

      return diskons;
    } catch (e) {
      throw ServerException('Gagal mengambil diskon: ${e.toString()}');
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

  // Menu-Diskon junction operations

  /// Link discount to menu items
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
        final docRef = collection.doc();
        batch.set(docRef, {
          'menuId': menuId,
          'diskonId': diskonId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(
        'Gagal menghubungkan diskon ke menu: ${e.toString()}',
      );
    }
  }

  /// Unlink discount from menu items
  Future<void> unlinkDiskonFromMenu({
    required String diskonId,
    required List<String> menuIds,
  }) async {
    try {
      final collection = _firestore.collection(
        AppConstants.menuDiskonCollection,
      );

      for (final menuId in menuIds) {
        final snapshot = await collection
            .where('menuId', isEqualTo: menuId)
            .where('diskonId', isEqualTo: diskonId)
            .get();

        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      throw ServerException(
        'Gagal memutus hubungan diskon dari menu: ${e.toString()}',
      );
    }
  }

  /// Get menu IDs that have a discount
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

  /// Get discount for a menu item (if any)
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

  /// Get all active discounts for a menu item
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
