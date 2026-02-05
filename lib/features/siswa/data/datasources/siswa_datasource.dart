import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/siswa_model.dart';

/// Remote datasource for student operations
abstract class SiswaRemoteDatasource {
  /// Create siswa profile after registration
  Future<SiswaModel> createSiswa({
    required String userId,
    required String namaSiswa,
    required String alamat,
    required String telp,
    required String fotoPath, // Local file path to upload
  });

  /// Get siswa profile by user ID
  Future<SiswaModel> getSiswaByUserId(String userId);

  /// Get siswa profile by siswa ID
  Future<SiswaModel> getSiswaById(String siswaId);

  /// Update siswa profile
  Future<SiswaModel> updateSiswa({
    required String siswaId,
    String? namaSiswa,
    String? alamat,
    String? telp,
    String? fotoPath, // Optional: new photo path
  });

  /// Increment daily order count
  Future<void> incrementDailyOrderCount(String siswaId);

  /// Reset daily order count (called when date changes)
  Future<void> resetDailyOrderCount(String siswaId);

  /// Check if siswa can place order (daily limit check)
  Future<bool> canPlaceOrder(String siswaId);
}

class SiswaRemoteDatasourceImpl implements SiswaRemoteDatasource {
  final FirebaseFirestore _firestore;

  SiswaRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<SiswaModel> createSiswa({
    required String userId,
    required String namaSiswa,
    required String alamat,
    required String telp,
    required String fotoPath,
  }) async {
    try {
      final docRef = _firestore.collection('siswa').doc();
      final today = DateTime.now().toIso8601String().split('T')[0];

      final siswaModel = SiswaModel(
        id: docRef.id,
        userId: userId,
        namaSiswa: namaSiswa,
        alamat: alamat,
        telp: telp,
        foto: fotoPath, // Will be URL from Cloudinary
        dailyOrderCount: 0,
        lastOrderDate: today,
      );

      await docRef.set(siswaModel.toFirestore());
      return siswaModel;
    } catch (e) {
      throw ServerException('Gagal membuat profil siswa: ${e.toString()}');
    }
  }

  @override
  Future<SiswaModel> getSiswaByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('siswa')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw NotFoundException('Profil siswa tidak ditemukan');
      }

      return SiswaModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Gagal mengambil profil siswa: ${e.toString()}');
    }
  }

  @override
  Future<SiswaModel> getSiswaById(String siswaId) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal mengambil profil siswa: ${e.toString()}');
    }
  }

  @override
  Future<SiswaModel> updateSiswa({
    required String siswaId,
    String? namaSiswa,
    String? alamat,
    String? telp,
    String? fotoPath,
  }) async {
    try {
      final docRef = _firestore.collection('siswa').doc(siswaId);
      final Map<String, dynamic> updates = {};

      if (namaSiswa != null) updates['namaSiswa'] = namaSiswa;
      if (alamat != null) updates['alamat'] = alamat;
      if (telp != null) updates['telp'] = telp;
      if (fotoPath != null) updates['foto'] = fotoPath;

      if (updates.isEmpty) {
        throw ServerException('Tidak ada data yang diupdate');
      }

      await docRef.update(updates);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw NotFoundException('Profil siswa tidak ditemukan');
      }

      return SiswaModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Gagal mengupdate profil siswa: ${e.toString()}');
    }
  }

  @override
  Future<void> incrementDailyOrderCount(String siswaId) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal menambahkan jumlah pesanan harian: ${e.toString()}');
    }
  }

  @override
  Future<void> resetDailyOrderCount(String siswaId) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal mereset jumlah pesanan harian: ${e.toString()}');
    }
  }

  @override
  Future<bool> canPlaceOrder(String siswaId) async {
    try {
      // Implementation will go here
      throw UnimplementedError();
    } catch (e) {
      throw ServerException('Gagal memeriksa apakah siswa dapat memesan: ${e.toString()}');
    }
  }
}