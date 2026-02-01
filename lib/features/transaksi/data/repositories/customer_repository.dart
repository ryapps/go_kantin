import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:kantin_app/features/auth/data/models/user_model.dart';
import 'package:kantin_app/features/transaksi/domain/entities/customer.dart';
import 'package:kantin_app/features/transaksi/domain/repositories/i_customer_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../models/customer_model.dart';

class CustomerRepository implements ICustomerRepository {
  final FirebaseFirestore _firestore;

  CustomerRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, Customer>> saveCustomerFromOrder({
    required String siswaId,
    required String siswaName,
    required String email,
    required double orderAmount,
  }) async {
    try {
      final customerRef = _firestore
          .collection(AppConstants.customerCollection)
          .doc(siswaId);

      // Get current customer data or create new one
      final docSnapshot = await customerRef.get();

      CustomerModel customerModel;
      if (docSnapshot.exists) {
        // Update existing customer
        final existingData = docSnapshot.data()!;
        final currentOrders =
            (existingData['totalOrders'] as num?)?.toInt() ?? 0;
        final currentSpent =
            (existingData['totalSpent'] as num?)?.toDouble() ?? 0.0;
        final lastOrderDate = (existingData['lastOrderDate'] as Timestamp?)
            ?.toDate();

        customerModel = CustomerModel(
          id: siswaId,
          userId: siswaId,
          name: siswaName,
          email: email,
          role: 'siswa', // Assuming role is always 'siswa' for students
          totalOrders: currentOrders + 1,
          totalSpent: currentSpent + orderAmount,
          lastOrderDate: DateTime.now(),
          createdAt:
              (existingData['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        // Create new customer
        customerModel = CustomerModel(
          id: siswaId,
          userId: siswaId,
          name: siswaName,
          email: email,
          role: 'siswa',
          totalOrders: 1,
          totalSpent: orderAmount,
          lastOrderDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      // Save to Firestore
      await customerRef.set(customerModel.toFirestore());

      return Right(customerModel.toEntity());
    } catch (e) {
      return Left(
        ServerFailure('Gagal menyimpan data pelanggan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(String customerId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.customerCollection)
          .doc(customerId)
          .get();

      if (!docSnapshot.exists) {
        return Left(ServerFailure('Customer tidak ditemukan'));
      }

      final customerModel = CustomerModel.fromFirestore(docSnapshot, null);
      return Right(customerModel.toEntity());
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengambil data pelanggan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getAllCustomers() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.customerCollection)
          .orderBy('totalSpent', descending: true) // Order by spending
          .get();

      final customers = snapshot.docs.map((doc) {
        return CustomerModel.fromFirestore(doc, null).toEntity();
      }).toList();

      return Right(customers);
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengambil semua pelanggan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Customer>> createCustomer({
    required String userId,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      final customerRef = _firestore
          .collection(AppConstants.customerCollection)
          .doc(userId);

      // Check if customer already exists
      final docSnapshot = await customerRef.get();
      if (docSnapshot.exists) {
        return Left(ServerFailure('Customer sudah ada'));
      }

      final now = DateTime.now();
      final customerModel = CustomerModel(
        id: userId,
        userId: userId,
        name: name,
        email: email,
        role: role,
        totalOrders: 0,
        totalSpent: 0.0,
        lastOrderDate: null,
        createdAt: now,
        updatedAt: now,
      );

      await customerRef.set(customerModel.toFirestore());

      return Right(customerModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Gagal membuat customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> createCustomerWithAccount({
    required String userId,
    required String name,
    required String email,
    required String role,
    required String password,
  }) async {
    try {
      // Store the current user ID to preserve admin session
      final firebaseAuth = firebase_auth.FirebaseAuth.instance;
      final currentUserId = firebaseAuth.currentUser?.uid;

      // Create user account in Firebase Auth first
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Left(ServerFailure('Gagal membuat akun pengguna'));
      }

      // Use the Firebase UID as the consistent identifier
      final actualUserId = firebaseUser.uid;

      final customerRef = _firestore
          .collection(AppConstants.customerCollection)
          .doc(actualUserId);
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(actualUserId);

      // Check if customer already exists (using the actual Firebase UID)
      final customerDocSnapshot = await customerRef.get();
      final userDocSnapshot = await userRef.get();

      if (customerDocSnapshot.exists || userDocSnapshot.exists) {
        // Clean up the created user if there's a conflict
        await firebaseUser.delete();
        return Left(ServerFailure('Customer atau akun sudah ada'));
      }

      // Create user document in Firestore
      final user = UserModel(
        id: actualUserId,
        username: name,
        role: role,
        createdAt: Timestamp.now(),
      );

      await userRef.set(user.toFirestore());

      // Create customer document in Firestore
      final now = DateTime.now();
      final customerModel = CustomerModel(
        id: actualUserId,
        userId: actualUserId,
        name: name,
        email: email,
        role: role,
        totalOrders: 0,
        totalSpent: 0.0,
        lastOrderDate: null,
        createdAt: now,
        updatedAt: now,
      );

      await customerRef.set(customerModel.toFirestore());

      return Right(customerModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(ServerFailure('Gagal membuat akun: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('Gagal membuat customer dengan akun: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer({
    required String customerId,
    String? name,
    String? email,
  }) async {
    return updateCustomerAndProfile(
      customerId: customerId,
      name: name,
      email: email,
    );
  }

  @override
  Future<Either<Failure, Customer>> updateCustomerAndProfile({
    required String customerId,
    String? name,
    String? email,
  }) async {
    try {
      final customerRef = _firestore
          .collection(AppConstants.customerCollection)
          .doc(customerId);
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(customerId);

      // Check if customer exists
      final customerDocSnapshot = await customerRef.get();
      if (!customerDocSnapshot.exists) {
        return Left(ServerFailure('Customer tidak ditemukan'));
      }

      // Prepare update data for customer
      final customerUpdateData = <String, dynamic>{};
      if (name != null) customerUpdateData['name'] = name;
      if (email != null) customerUpdateData['email'] = email;
      customerUpdateData['updatedAt'] = Timestamp.fromDate(DateTime.now());

      // Update customer document
      await customerRef.update(customerUpdateData);

      // Update user document if it exists
      final userDocSnapshot = await userRef.get();
      if (userDocSnapshot.exists) {
        final userUpdateData = <String, dynamic>{};
        if (name != null) userUpdateData['username'] = name;
        if (email != null) userUpdateData['email'] = email;

        await userRef.update(userUpdateData);
      }

      // Return updated customer
      final updatedDoc = await customerRef.get();
      final customerModel = CustomerModel.fromFirestore(updatedDoc, null);
      return Right(customerModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Gagal mengupdate customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String customerId) async {
    try {
      final customerRef = _firestore
          .collection(AppConstants.customerCollection)
          .doc(customerId);

      // Check if customer exists
      final docSnapshot = await customerRef.get();
      if (!docSnapshot.exists) {
        return Left(ServerFailure('Customer tidak ditemukan'));
      }

      await customerRef.delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Gagal menghapus customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomerAndAccount(
    String customerId,
  ) async {
    try {
      final customerRef = _firestore
          .collection(AppConstants.customerCollection)
          .doc(customerId);
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(customerId);

      // Check if customer exists
      final customerDocSnapshot = await customerRef.get();
      if (!customerDocSnapshot.exists) {
        return Left(ServerFailure('Customer tidak ditemukan'));
      }

      // Delete customer document
      await customerRef.delete();

      // Delete user document if it exists
      final userDocSnapshot = await userRef.get();
      if (userDocSnapshot.exists) {
        await userRef.delete();
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Gagal menghapus customer dan akun: ${e.toString()}'),
      );
    }
  }
}
