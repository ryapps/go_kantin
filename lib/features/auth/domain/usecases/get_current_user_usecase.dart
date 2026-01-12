import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class GetCurrentUserUseCase implements UseCaseNoParams<User?> {
  final IAuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call() async {
    return await repository.getCurrentUser();
  }
}