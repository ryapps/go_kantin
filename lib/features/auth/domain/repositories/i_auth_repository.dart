import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Auth repository interface
/// Uses Either<Failure, Success> for error handling
abstract class IAuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Register new user (returns user after registration)
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String username,
    required String role,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Listen to auth state changes
  Stream<User?> get authStateChanges;

  /// Update user role (admin only)
  Future<Either<Failure, void>> updateUserRole({
    required String userId,
    required String newRole,
  });

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount(String userId);

  /// Sign in with Google
  Future<Either<Failure, User>> googleSignIn();
}
