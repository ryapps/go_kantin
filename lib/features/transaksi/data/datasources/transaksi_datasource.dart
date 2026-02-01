import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/detail_transaksi_model.dart';
import '../models/transaksi_model.dart';

/// Remote datasource for transaction operations
abstract class TransaksiRemoteDatasource {
  /// Place new order (creates transaksi with details)
  Future<TransaksiModel> placeOrder({
    required String siswaId,
    required String stanId,
    required List<DetailTransaksiModel> items,
  });

  /// Get transaksi by ID
  Future<TransaksiModel> getTransaksiById(String transaksiId);

  /// Get all transaksi for a student
  Future<List<TransaksiModel>> getTransaksiByStudent(String siswaId);

  /// Get all transaksi for a stan (stall owner view)
  Future<List<TransaksiModel>> getTransaksiByStan(String stanId);

  /// Get all transaksi (super admin view)
  Future<List<TransaksiModel>> getAllTransaksi();

  /// Update transaksi status
  Future<TransaksiModel> updateTransaksiStatus({
    required String transaksiId,
    required String newStatus,
  });

  /// Cancel transaksi (only if status is belum_dikonfirm)
  Future<void> cancelTransaksi(String transaksiId);

  /// Stream transaksi by student (for real-time updates)
  Stream<List<TransaksiModel>> watchTransaksiByStudent(String siswaId);

  /// Stream transaksi by stan (for real-time order queue)
  Stream<List<TransaksiModel>> watchTransaksiByStan(String stanId);

  /// Stream single transaksi (for order tracking)
  Stream<TransaksiModel> watchTransaksiById(String transaksiId);

  // Offline operations

  /// Queue order for offline sync
  Future<void> queueOfflineOrder({
    required String siswaId,
    required String stanId,
    required List<DetailTransaksiModel> items,
  });

  /// Get all queued offline orders
  Future<List<Map<String, dynamic>>> getOfflineOrders();

  /// Sync queued orders when back online
  Future<List<TransaksiModel>> syncOfflineOrders();

  /// Clear offline order after successful sync
  Future<void> clearOfflineOrder(String localOrderId);
}

class TransaksiRemoteDatasourceImpl implements TransaksiRemoteDatasource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  TransaksiRemoteDatasourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<TransaksiModel> placeOrder({
    required String siswaId,
    required String stanId,
    required List<DetailTransaksiModel> items,
  }) async {
    try {
      final transaksiRef = _firestore
          .collection(AppConstants.transaksiCollection)
          .doc();

      final siswaName = await _getSiswaName(siswaId);
      final stanName = await _getStanName(stanId);
      final email = await _getSiswaEmail(siswaId); // Get student email

      final itemsWithTransaksiId = items.map((item) {
        return item.copyWith(
          id: item.id.isEmpty ? _uuid.v4() : item.id,
          transaksiId: transaksiRef.id,
        );
      }).toList();

      final totalAmount = itemsWithTransaksiId.fold<double>(
        0,
        (sum, item) => sum + (item.hargaBeli * item.qty),
      );
      final totalDiscount = itemsWithTransaksiId.fold<double>(
        0,
        (sum, item) => sum + item.discountAmount,
      );
      final finalAmount = itemsWithTransaksiId.fold<double>(
        0,
        (sum, item) => sum + item.subtotal,
      );

      final now = Timestamp.now();
      final transaksiModel = TransaksiModel(
        id: transaksiRef.id,
        siswaId: siswaId,
        siswaName: siswaName,
        stanId: stanId,
        stanName: stanName,
        items: itemsWithTransaksiId,
        totalAmount: totalAmount,
        totalDiscount: totalDiscount,
        finalAmount: finalAmount,
        status: AppConstants.statusBelumDikonfirm,
        createdAt: now,
        updatedAt: now,
      );

      await transaksiRef.set(transaksiModel.toFirestore());

      // Save/update customer data in the customer collection
      await _saveCustomerData(
        siswaId: siswaId,
        siswaName: siswaName,
        email: email,
        orderAmount: finalAmount,
      );

      return transaksiModel;
    } catch (e) {
      throw ServerException('Gagal membuat transaksi: ${e.toString()}');
    }
  }

  @override
  Future<TransaksiModel> getTransaksiById(String transaksiId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.transaksiCollection)
          .doc(transaksiId)
          .get();

      if (!doc.exists) {
        throw NotFoundException('Transaksi tidak ditemukan');
      }

      final items = _parseDetailItems(doc.data()?['items']);
      return TransaksiModel.fromFirestore(doc, items);
    } catch (e) {
      throw ServerException('Gagal mengambil transaksi: ${e.toString()}');
    }
  }

  @override
  Future<List<TransaksiModel>> getTransaksiByStudent(String siswaId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.transaksiCollection)
          .where('siswaId', isEqualTo: siswaId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final items = _parseDetailItems(doc.data()['items']);
        return TransaksiModel.fromFirestore(doc, items);
      }).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil transaksi siswa: ${e.toString()}');
    }
  }

  @override
  Future<List<TransaksiModel>> getTransaksiByStan(String stanId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.transaksiCollection)
          .where('stanId', isEqualTo: stanId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final items = _parseDetailItems(doc.data()['items']);
        return TransaksiModel.fromFirestore(doc, items);
      }).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil transaksi stan: ${e.toString()}');
    }
  }

  @override
  Future<List<TransaksiModel>> getAllTransaksi() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.transaksiCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final items = _parseDetailItems(doc.data()['items']);
        return TransaksiModel.fromFirestore(doc, items);
      }).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil semua transaksi: ${e.toString()}');
    }
  }

  @override
  Future<TransaksiModel> updateTransaksiStatus({
    required String transaksiId,
    required String newStatus,
  }) async {
    try {
      final ref = _firestore
          .collection(AppConstants.transaksiCollection)
          .doc(transaksiId);

      await ref.update({'status': newStatus, 'updatedAt': Timestamp.now()});
      final doc = await ref.get();

      if (!doc.exists) {
        throw NotFoundException('Transaksi tidak ditemukan');
      }

      final items = _parseDetailItems(doc.data()?['items']);
      return TransaksiModel.fromFirestore(doc, items);
    } catch (e) {
      throw ServerException(
        'Gagal mengupdate status transaksi: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cancelTransaksi(String transaksiId) async {
    try {
      await _firestore
          .collection(AppConstants.transaksiCollection)
          .doc(transaksiId)
          .update({
            'status': AppConstants.statusDibatalkan,
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      throw ServerException('Gagal membatalkan transaksi: ${e.toString()}');
    }
  }

  @override
  Stream<List<TransaksiModel>> watchTransaksiByStudent(String siswaId) {
    return _firestore
        .collection(AppConstants.transaksiCollection)
        .where('siswaId', isEqualTo: siswaId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final items = _parseDetailItems(doc.data()['items']);
            return TransaksiModel.fromFirestore(doc, items);
          }).toList(),
        );
  }

  @override
  Stream<List<TransaksiModel>> watchTransaksiByStan(String stanId) {
    return _firestore
        .collection(AppConstants.transaksiCollection)
        .where('stanId', isEqualTo: stanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final items = _parseDetailItems(doc.data()['items']);
            return TransaksiModel.fromFirestore(doc, items);
          }).toList(),
        );
  }

  @override
  Stream<TransaksiModel> watchTransaksiById(String transaksiId) {
    return _firestore
        .collection(AppConstants.transaksiCollection)
        .doc(transaksiId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw NotFoundException('Transaksi tidak ditemukan');
          }
          final items = _parseDetailItems(doc.data()?['items']);
          return TransaksiModel.fromFirestore(doc, items);
        });
  }

  @override
  Future<void> queueOfflineOrder({
    required String siswaId,
    required String stanId,
    required List<DetailTransaksiModel> items,
  }) async {
    try {
      final box = await Hive.openBox<Map>(AppConstants.offlineOrdersBox);
      final localOrderId = _uuid.v4();
      await box.put(localOrderId, {
        'localOrderId': localOrderId,
        'siswaId': siswaId,
        'stanId': stanId,
        'items': items.map((item) => item.toJson()).toList(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(
        'Gagal menyimpan transaksi offline: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOfflineOrders() async {
    try {
      final box = await Hive.openBox<Map>(AppConstants.offlineOrdersBox);
      return box.values
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
    } catch (e) {
      throw ServerException(
        'Gagal mengambil transaksi offline: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<TransaksiModel>> syncOfflineOrders() async {
    try {
      final box = await Hive.openBox<Map>(AppConstants.offlineOrdersBox);
      final synced = <TransaksiModel>[];

      for (final entry in box.toMap().entries) {
        final value = Map<String, dynamic>.from(entry.value);
        final itemsJson = value['items'] as List<dynamic>? ?? [];
        final items = itemsJson
            .map((item) => DetailTransaksiModel.fromJson(item))
            .toList();

        final transaksi = await placeOrder(
          siswaId: value['siswaId'] as String,
          stanId: value['stanId'] as String,
          items: items,
        );
        synced.add(transaksi);
        await box.delete(entry.key);
      }

      return synced;
    } catch (e) {
      throw ServerException(
        'Gagal menyinkronkan transaksi offline: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearOfflineOrder(String localOrderId) async {
    try {
      final box = await Hive.openBox<Map>(AppConstants.offlineOrdersBox);
      await box.delete(localOrderId);
    } catch (e) {
      throw ServerException(
        'Gagal menghapus transaksi offline: ${e.toString()}',
      );
    }
  }

  List<DetailTransaksiModel> _parseDetailItems(dynamic rawItems) {
    if (rawItems is! List) return [];

    return rawItems
        .map(
          (item) => DetailTransaksiModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<String> _getSiswaName(String siswaId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(siswaId)
          .get();
      return doc.data()?['username'] ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<String> _getSiswaEmail(String siswaId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(siswaId)
          .get();
      return doc.data()?['email'] ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<String> _getStanName(String stanId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.stanCollection)
          .doc(stanId)
          .get();
      return doc.data()?['namaStan'] ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _saveCustomerData({
    required String siswaId,
    required String siswaName,
    required String email,
    required double orderAmount,
  }) async {
    try {
      final customerRef = _firestore.collection(AppConstants.customerCollection).doc(siswaId);

      // Get current customer data or create new one
      final docSnapshot = await customerRef.get();

      if (docSnapshot.exists) {
        // Update existing customer
        final existingData = docSnapshot.data()!;
        final currentOrders = (existingData['totalOrders'] as num?)?.toInt() ?? 0;
        final currentSpent = (existingData['totalSpent'] as num?)?.toDouble() ?? 0.0;

        await customerRef.update({
          'totalOrders': currentOrders + 1,
          'totalSpent': currentSpent + orderAmount,
          'lastOrderDate': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      } else {
        // Create new customer
        await customerRef.set({
          'userId': siswaId,
          'name': siswaName,
          'email': email,
          'role': 'siswa',
          'totalOrders': 1,
          'totalSpent': orderAmount,
          'lastOrderDate': Timestamp.now(),
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      // Log the error but don't throw it, as we don't want to fail the transaction
      // due to customer data saving issue
      print('Error saving customer data: ${e.toString()}');
    }
  }
}
