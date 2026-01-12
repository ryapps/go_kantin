import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

/// Remote datasource for authentication operations
abstract class AuthRemoteDatasource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String role,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<bool> isAuthenticated();

  Stream<UserModel?> watchAuthState();

  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  });

  Future<void> deleteAccount(String userId);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDatasourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  // ===================== EMAIL LOGIN =====================

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Login gagal');
      }

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw NotFoundException('Data user tidak ditemukan');
      }

      return UserModel.fromFirestore(doc);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  // ===================== REGISTER =====================

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Registrasi gagal');
      }

      final userModel = UserModel(
        id: user.uid,
        username: username,
        role: role,
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  // ===================== GOOGLE SIGN IN =====================

  @override
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Sign out first to get a fresh authentication
      await _googleSignIn.signOut();

      // Perform sign in
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google Sign In dibatalkan');
      }

      // Get authentication credentials
      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw AuthException('ID Token Google tidak tersedia');
      }

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException('Login Google gagal');
      }

      // Check if user exists in Firestore
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid);

      final doc = await userRef.get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      // Create new user document
      final newUser = UserModel(
        id: firebaseUser.uid,
        username: firebaseUser.displayName ?? firebaseUser.email ?? 'User',
        role: 'siswa',
        createdAt: Timestamp.now(),
      );

      await userRef.set(newUser.toFirestore());
      return newUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } on AuthException catch (e) {
      rethrow;
    } catch (e) {
      throw ServerException('Google Sign In gagal: ${e.toString()}');
    }
  }

  // ===================== AUTH STATE =====================

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ===================== ACCOUNT =====================

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'role': newRole});
  }

  @override
  Future<void> deleteAccount(String userId) async {
    final user = _firebaseAuth.currentUser;

    if (user == null || user.uid != userId) {
      throw AuthException('User tidak valid');
    }

    try {
      await user.delete();
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException('Silakan login ulang sebelum menghapus akun');
      }
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  // ===================== ERROR MAPPING =====================

  String _mapFirebaseAuthError(String code) {
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
        return 'Terjadi kesalahan ($code)';
    }
  }
}
