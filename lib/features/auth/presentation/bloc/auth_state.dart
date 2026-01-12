import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Base class for all Auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication error occurred
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Registration successful (but might need profile completion)
class RegistrationSuccess extends AuthState {
  final User user;

  const RegistrationSuccess(this.user);

  @override
  List<Object?> get props => [user];
}