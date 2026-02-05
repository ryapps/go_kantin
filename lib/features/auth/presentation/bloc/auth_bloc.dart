import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final WatchAuthStateUseCase _watchAuthStateUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;

  StreamSubscription? _authStateSubscription;
  bool _isAdminCreatingCustomer =
      false; // Flag to track if admin is creating customer
  bool _isRegistering = false; // Flag to track if user is registering
  User? _originalAdminUser; // Store the original admin user

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required WatchAuthStateUseCase watchAuthStateUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _watchAuthStateUseCase = watchAuthStateUseCase,
       _googleSignInUseCase = googleSignInUseCase,
       super(const AuthInitial()) {
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStateChangeSubscribed>(_onAuthStateChangeSubscribed);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AdminCreatingCustomerStarted>(_onAdminCreatingCustomerStarted);
    on<AdminCreatingCustomerCompleted>(_onAdminCreatingCustomerCompleted);
  }

  /// Check current authentication status
  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getCurrentUserUseCase();

    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      if (user != null) {
        _originalAdminUser =
            user; // Store the current user as original admin user
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      // Emit authenticated user regardless of role selection
      // Role validation will be handled in the UI layer
      _originalAdminUser =
          user; // Store the current user as original admin user
      emit(Authenticated(user));
    });
  }

  /// Handle registration request
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _isRegistering = true; // Set flag to prevent auto-redirect

    final result = await _registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        username: event.username,
        role: event.role,
      ),
    );

    await result.fold(
      (failure) async {
        _isRegistering = false;
        emit(AuthError(failure.message));
      },
      (user) async {
        // Logout immediately after registration to prevent auto-login
        await _logoutUseCase();
        _isRegistering = false;
        if (!emit.isDone) {
          emit(RegistrationSuccess(user));
        }
      },
    );
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Log user role position before logout
    print('User with role "${event.role}" is logging out');

    final result = await _logoutUseCase();

    result.fold((failure) => emit(AuthError(failure.message)), (_) {
      _originalAdminUser = null; // Clear the stored admin user
      print('User with role "${event.role}" has successfully logged out');
      return emit(const Unauthenticated());
    });
  }

  /// Subscribe to auth state changes from Firebase
  Future<void> _onAuthStateChangeSubscribed(
    AuthStateChangeSubscribed event,
    Emitter<AuthState> emit,
  ) async {
    _authStateSubscription?.cancel();

    await emit.forEach<User?>(
      _watchAuthStateUseCase(),
      onData: (user) {
        // If admin is creating customer or user is registering, ignore the auth state change temporarily
        if (_isAdminCreatingCustomer || _isRegistering) {
          // Don't emit anything, just return the current state
          return state;
        }

        if (user != null) {
          return Authenticated(user);
        } else {
          return const Unauthenticated();
        }
      },
      onError: (error, stackTrace) => AuthError(error.toString()),
    );
  }

  /// Handle Google Sign In request
  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _googleSignInUseCase(
      GoogleSignInParams(role: event.role),
    );

    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      _originalAdminUser =
          user; // Store the current user as original admin user
      emit(Authenticated(user));
    });
  }

  /// Handle admin starting to create customer
  void _onAdminCreatingCustomerStarted(
    AdminCreatingCustomerStarted event,
    Emitter<AuthState> emit,
  ) {
    _isAdminCreatingCustomer = true;
  }

  /// Handle admin completing customer creation
  void _onAdminCreatingCustomerCompleted(
    AdminCreatingCustomerCompleted event,
    Emitter<AuthState> emit,
  ) {
    _isAdminCreatingCustomer = false;

    // Emit the original admin user state after customer creation
    // If original admin user is provided in the event, use that
    // Otherwise, try to get the current user (which might be the new customer)
    if (event.originalAdminUser != null) {
      emit(Authenticated(event.originalAdminUser!));
    } else if (_originalAdminUser != null) {
      // If we have stored the original admin user, restore that session
      emit(Authenticated(_originalAdminUser!));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
