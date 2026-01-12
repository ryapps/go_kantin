import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

/// Use case for user registration
class RegisterUseCase implements UseCase<User, RegisterParams> {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      username: params.username,
      role: params.role,
    );
  }
}

/// Parameters for register use case
class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String username;
  final String role;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.username,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, username, role];
}