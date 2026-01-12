import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server/Firebase related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Permission/Authorization failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Business logic failures (e.g., daily limit reached)
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure(super.message);
}