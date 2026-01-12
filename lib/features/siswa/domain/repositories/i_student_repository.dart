import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/siswa.dart';

/// Siswa repository interface
abstract class ISiswaRepository {
  /// Create siswa profile after registration
  Future<Either<Failure, Siswa>> createSiswa({
    required String userId,
    required String namaSiswa,
    required String alamat,
    required String telp,
    required String fotoPath, // Local file path to upload
  });

  /// Get siswa profile by user ID
  Future<Either<Failure, Siswa>> getSiswaByUserId(String userId);

  /// Get siswa profile by siswa ID
  Future<Either<Failure, Siswa>> getSiswaById(String siswaId);

  /// Update siswa profile
  Future<Either<Failure, Siswa>> updateSiswa({
    required String siswaId,
    String? namaSiswa,
    String? alamat,
    String? telp,
    String? fotoPath, // Optional: new photo path
  });

  /// Increment daily order count
  Future<Either<Failure, void>> incrementDailyOrderCount(String siswaId);

  /// Reset daily order count (called when date changes)
  Future<Either<Failure, void>> resetDailyOrderCount(String siswaId);

  /// Check if siswa can place order (daily limit check)
  Future<Either<Failure, bool>> canPlaceOrder(String siswaId);
}