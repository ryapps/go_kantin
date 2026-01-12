import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepository implements IAuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepository({
    required AuthRemoteDatasource datasource,
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _datasource = datasource;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _datasource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return Left(AuthFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    try {
      final userModel = await _datasource.registerWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        role: role,
      );
      return Right(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return Left(AuthFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _datasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Logout gagal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await _datasource.getCurrentUser();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(AuthFailure('Gagal mengambil data user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuthenticated = await _datasource.isAuthenticated();
      return Right(isAuthenticated);
    } catch (e) {
      return const Left(AuthFailure('Gagal memeriksa status login'));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _datasource.watchAuthState().map(
      (userModel) => userModel?.toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      await _datasource.updateUserRole(userId: userId, newRole: newRole);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Gagal update role: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String userId) async {
    try {
      await _datasource.deleteAccount(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Gagal hapus akun: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> googleSignIn() async {
    try {
      final userModel = await _datasource.signInWithGoogle();
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure('Google Sign In gagal: ${e.toString()}'));
    }
  }

  /// Map Firebase error codes to user-friendly messages
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return ErrorMessages.userNotFound;
      case 'wrong-password':
        return ErrorMessages.wrongPassword;
      case 'email-already-in-use':
        return ErrorMessages.emailAlreadyInUse;
      case 'invalid-email':
        return ErrorMessages.invalidEmail;
      case 'weak-password':
        return ErrorMessages.weakPassword;
      case 'user-disabled':
        return ErrorMessages.userDisabled;
      case 'network-request-failed':
        return ErrorMessages.noInternetConnection;
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
