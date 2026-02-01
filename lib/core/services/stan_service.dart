import 'package:dartz/dartz.dart';
import '../../features/stan/domain/repositories/i_stan_repository.dart';
import '../../features/stan/domain/entities/stan.dart';
import '../error/failures.dart';

/// Service class to handle stan-related operations
class StanService {
  final IStanRepository _stanRepository;

  StanService(this._stanRepository);

  /// Get stan ID by user ID
  /// This method retrieves the stan associated with a specific user and returns its ID
  /// 
  /// Returns [Either] with [Failure] on error or [String] (stanId) on success
  Future<Either<Failure, String>> getStanIdByUserId(String userId) async {
    try {
      final result = await _stanRepository.getStanByUserId(userId);
      return result.fold(
        (failure) => Left(failure),
        (stan) => Right(stan.id),
      );
    } catch (e) {
      return const Left(ServerFailure('Gagal mendapatkan ID stan'));
    }
  }

  /// Get stan entity by user ID
  /// This method retrieves the complete stan entity associated with a specific user
  /// 
  /// Returns [Either] with [Failure] on error or [Stan] entity on success
  Future<Either<Failure, Stan>> getStanByUserId(String userId) async {
    try {
      return await _stanRepository.getStanByUserId(userId);
    } catch (e) {
      return const Left(ServerFailure('Gagal mendapatkan data stan'));
    }
  }

  /// Check if user has a stan
  /// This method checks whether a user has an associated stan
  /// 
  /// Returns [Either] with [Failure] on error or [bool] (true if user has stan) on success
  Future<Either<Failure, bool>> userHasStan(String userId) async {
    try {
      final result = await _stanRepository.getStanByUserId(userId);
      return result.fold(
        (failure) => const Right(false), // If failure occurs (e.g., stan not found), return false
        (stan) => const Right(true), // If stan is found, return true
      );
    } catch (e) {
      return const Right(false); // If exception occurs, return false
    }
  }
}