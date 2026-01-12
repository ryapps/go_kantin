import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_auth_repository.dart';

class LogoutUseCase implements UseCaseNoParams<void> {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}