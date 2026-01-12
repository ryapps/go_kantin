import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

/// Use case to watch auth state changes (stream)
class WatchAuthStateUseCase {
  final IAuthRepository repository;

  WatchAuthStateUseCase(this.repository);

  /// Returns stream of user auth state
  Stream<User?> call() {
    return repository.authStateChanges;
  }
}