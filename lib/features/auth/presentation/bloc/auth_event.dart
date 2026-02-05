import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/auth/domain/entities/user.dart';

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

  const LoginRequested({required this.email, required this.password});

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
  final String role;

  const LogoutRequested({required this.role});

  @override
  List<Object?> get props => [role];
}

/// Listen to auth state changes
class AuthStateChangeSubscribed extends AuthEvent {
  const AuthStateChangeSubscribed();
}

/// Sign in with Google
class GoogleSignInRequested extends AuthEvent {
  final String role;

  const GoogleSignInRequested({this.role = 'siswa'});

  @override
  List<Object> get props => [role];
}

/// Event emitted when admin starts creating customer account
class AdminCreatingCustomerStarted extends AuthEvent {
  const AdminCreatingCustomerStarted();

  @override
  List<Object> get props => [];
}

/// Event emitted when admin completes customer creation
class AdminCreatingCustomerCompleted extends AuthEvent {
  final User? originalAdminUser;

  const AdminCreatingCustomerCompleted({this.originalAdminUser});

  @override
  List<Object?> get props => [originalAdminUser];
}
