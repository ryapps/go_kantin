import 'package:dartz/dartz.dart';
import '../../features/stan/domain/repositories/i_stan_repository.dart';
import '../../core/error/failures.dart';

/// Utility functions for stan-related operations
class StanUtils {
  /// Get stan ID by user ID using the provided repository
  /// 
  /// This is a convenience method that can be used anywhere in the app
  /// to get the stan ID associated with a user ID
  /// 
  /// Example usage:
  /// ```dart
  /// final result = await StanUtils.getStanIdByUserId(stanRepository, userId);
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (stanId) => print('Stan ID: $stanId'),
  /// );
  /// ```
  static Future<Either<Failure, String>> getStanIdByUserId(
    IStanRepository stanRepository, 
    String userId,
  ) async {
    try {
      final result = await stanRepository.getStanByUserId(userId);
      return result.fold(
        (failure) => Left(failure),
        (stan) => Right(stan.id),
      );
    } catch (e) {
      return Left(ServerFailure('Gagal mendapatkan ID stan: ${e.toString()}'));
    }
  }

  /// Check if a user has a stan account
  /// 
  /// Returns true if the user has an associated stan, false otherwise
  static Future<bool> userHasStan(
    IStanRepository stanRepository, 
    String userId,
  ) async {
    try {
      final result = await stanRepository.getStanByUserId(userId);
      return result.fold(
        (failure) => false, // If failure (e.g., not found), user doesn't have stan
        (stan) => true,     // If success, user has stan
      );
    } catch (e) {
      return false; // If exception occurs, assume user doesn't have stan
    }
  }
}