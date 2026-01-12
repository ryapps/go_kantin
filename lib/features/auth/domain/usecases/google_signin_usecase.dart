import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

/// Use case for Google Sign In
class GoogleSignInUseCase implements UseCaseNoParams<User> {
  final IAuthRepository repository;

  GoogleSignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call() async {
    return await repository.googleSignIn();
  }
}
