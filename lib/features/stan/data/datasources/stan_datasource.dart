import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/stan_model.dart';

/// Remote datasource for stan operations
abstract class StanRemoteDatasource {
  /// Create new stan (stall owner registration)
  Future<StanModel> createStan({
    required String userId,
    required String namaStan,
    required String namaPemilik,
    required String telp,
    String? description,
    String? location,
    String? openTime,
    String? closeTime,
    String? imageUrl,
  });

  /// Get all active stans
  Future<List<StanModel>> getAllStans();

  /// Get stan by ID
  Future<StanModel> getStanById(String stanId);

  /// Get stan by owner's user ID
  Future<StanModel> getStanByUserId(String userId);

  /// Update stan information
  Future<StanModel> updateStan({
    required String stanId,
    String? namaStan,
    String? namaPemilik,
    String? telp,
    String? description,
    String? location,
    String? openTime,
    String? closeTime,
    String? imageUrl,
  });

  /// Activate stan
  Future<void> activateStan(String stanId);

  /// Deactivate stan
  Future<void> deactivateStan(String stanId);

  /// Delete stan (super admin only)
  Future<void> deleteStan(String stanId);

  /// Stream of all stans (for real-time updates)
  Stream<List<StanModel>> watchAllStans();
}

class StanRemoteDatasourceImpl implements StanRemoteDatasource {
  final FirebaseFirestore _firestore;

  StanRemoteDatasourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<StanModel> createStan({
    required String userId,
    required String namaStan,
    required String namaPemilik,
    required String telp,
    String? description,
    String? location,
    String? openTime,
    String? closeTime,
    String? imageUrl,
  }) async {
    try {
      final collection = _firestore.collection(AppConstants.stanCollection);
      final docRef = await collection.add({
        'userId': userId,
        'namaStan': namaStan,
        'namaPemilik': namaPemilik,
        'telp': telp,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'description': description ?? '',
        'imageUrl': imageUrl ?? 'https://via.placeholder.com/400x200?text=Stan',
        'rating': 0.0,
        'reviewCount': 0,
        'openTime': openTime ?? '08:00',
        'closeTime': closeTime ?? '17:00',
        'categories': <String>[],
        'location': location ?? '',
      });
      final snapshot = await docRef.get();
      return StanModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal membuat stan: ${e.toString()}');
    }
  }

  @override
  Future<List<StanModel>> getAllStans() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.stanCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(StanModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil semua stan: ${e.toString()}');
    }
  }

  @override
  Future<StanModel> getStanById(String stanId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.stanCollection)
          .doc(stanId)
          .get();
      if (!snapshot.exists) {
        throw ServerException('Stan tidak ditemukan');
      }
      return StanModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal mengambil stan: ${e.toString()}');
    }
  }

  @override
  Future<StanModel> getStanByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.stanCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw ServerException('Stan tidak ditemukan untuk user ini');
      }

      return StanModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw ServerException(
        'Gagal mengambil stan berdasarkan user: ${e.toString()}',
      );
    }
  }

  @override
  Future<StanModel> updateStan({
    required String stanId,
    String? namaStan,
    String? namaPemilik,
    String? telp,
    String? description,
    String? location,
    String? openTime,
    String? closeTime,
    String? imageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (namaStan != null) updateData['namaStan'] = namaStan;
      if (namaPemilik != null) updateData['namaPemilik'] = namaPemilik;
      if (telp != null) updateData['telp'] = telp;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (openTime != null) updateData['openTime'] = openTime;
      if (closeTime != null) updateData['closeTime'] = closeTime;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(AppConstants.stanCollection)
            .doc(stanId)
            .update(updateData);
      }

      final snapshot = await _firestore
          .collection(AppConstants.stanCollection)
          .doc(stanId)
          .get();
      if (!snapshot.exists) {
        throw ServerException('Stan tidak ditemukan');
      }
      return StanModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal mengupdate stan: ${e.toString()}');
    }
  }

  @override
  Future<void> activateStan(String stanId) async {
    try {
      await _firestore
          .collection(AppConstants.stanCollection)
          .doc(stanId)
          .update({'isActive': true});
    } catch (e) {
      throw ServerException('Gagal mengaktifkan stan: ${e.toString()}');
    }
  }

  @override
  Future<void> deactivateStan(String stanId) async {
    try {
      await _firestore
          .collection(AppConstants.stanCollection)
          .doc(stanId)
          .update({'isActive': false});
    } catch (e) {
      throw ServerException('Gagal menonaktifkan stan: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStan(String stanId) async {
    try {
      await _firestore
          .collection(AppConstants.stanCollection)
          .doc(stanId)
          .delete();
    } catch (e) {
      throw ServerException('Gagal menghapus stan: ${e.toString()}');
    }
  }

  @override
  Stream<List<StanModel>> watchAllStans() {
    return _firestore
        .collection(AppConstants.stanCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(StanModel.fromFirestore).toList());
  }
}
