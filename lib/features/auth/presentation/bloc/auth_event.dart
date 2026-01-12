import 'package:equatable/equatable.dart';

/// Base class for all Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current authentication status on app start
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// Login with email and password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register new user
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final String role;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.username,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, username, role];
}

/// Logout current user
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Listen to auth state changes
class AuthStateChangeSubscribed extends AuthEvent {
  const AuthStateChangeSubscribed();
}

/// Sign in with Google
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}