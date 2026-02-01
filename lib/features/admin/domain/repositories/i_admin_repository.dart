import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Admin repository interface for stan management
abstract class IAdminRepository {
  /// Register admin stan (creates user + stan profile)
  Future<Either<Failure, void>> registerAdminStan({
    required String username,
    required String email,
    required String password,
    required String namaStan,
    required String namaPemilik,
    required String telp,
    required String deskripsi,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    required String imageUrl,
  });

  /// Get stan by owner user ID
  Future<Either<Failure, dynamic>> getStanByUserId(String userId);

  /// Update stan profile
  Future<Either<Failure, void>> updateStan({
    required String stanId,
    required String namaStan,
    required String namaPemilik,
    required String telp,
    required String deskripsi,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    required String imageUrl,
  });

  /// Get all customers from Firestore
  Future<Either<Failure, List<dynamic>>> getAllCustomers();
}
