import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/stan.dart';

/// Stan repository interface
abstract class IStanRepository {
  /// Create new stan (stall owner registration)
  Future<Either<Failure, Stan>> createStan({
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

  /// Create new stan with all profile data (for profile completion)
  Future<Either<Failure, Stan>> createStanWithProfileData(Map<String, dynamic> stanData);

  /// Get all active stans
  Future<Either<Failure, List<Stan>>> getAllStans();

  /// Get stan by ID
  Future<Either<Failure, Stan>> getStanById(String stanId);

  /// Get stan by owner's user ID
  Future<Either<Failure, Stan>> getStanByUserId(String userId);

  /// Update stan information
  Future<Either<Failure, Stan>> updateStan({
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
  Future<Either<Failure, void>> activateStan(String stanId);

  /// Deactivate stan
  Future<Either<Failure, void>> deactivateStan(String stanId);

  /// Delete stan (super admin only)
  Future<Either<Failure, void>> deleteStan(String stanId);

  /// Stream of all stans (for real-time updates)
  Stream<Either<Failure, List<Stan>>> watchAllStans();
}
