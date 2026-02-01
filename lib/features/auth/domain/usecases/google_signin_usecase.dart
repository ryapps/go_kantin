import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

/// Use case for Google Sign In
class GoogleSignInUseCase implements UseCase<User, GoogleSignInParams> {
  final IAuthRepository repository;

  GoogleSignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(GoogleSignInParams params) async {
    return await repository.googleSignIn(role: params.role);
  }
}

class GoogleSignInParams {
  final String role;

  GoogleSignInParams({this.role = 'siswa'});
}
