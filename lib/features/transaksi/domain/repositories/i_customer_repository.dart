import 'package:dartz/dartz.dart';
import '../entities/customer.dart';
import '../../../../core/error/failures.dart';

abstract class ICustomerRepository {
  /// Save or update customer data when a student places an order
  Future<Either<Failure, Customer>> saveCustomerFromOrder({
    required String siswaId,
    required String siswaName,
    required String email,
    required double orderAmount,
  });

  /// Get customer by user ID
  Future<Either<Failure, Customer>> getCustomerById(String customerId);

  /// Get all customers
  Future<Either<Failure, List<Customer>>> getAllCustomers();

  /// Create a new customer
  Future<Either<Failure, Customer>> createCustomer({
    required String userId,
    required String name,
    required String email,
    required String role,
  });

  /// Create a new customer with login account
  Future<Either<Failure, Customer>> createCustomerWithAccount({
    required String userId,
    required String name,
    required String email,
    required String role,
    required String password,
  });

  /// Update an existing customer and user profile
  Future<Either<Failure, Customer>> updateCustomer({
    required String customerId,
    String? name,
    String? email,
  });

  /// Update customer and user profile
  Future<Either<Failure, Customer>> updateCustomerAndProfile({
    required String customerId,
    String? name,
    String? email,
  });

  /// Delete a customer
  Future<Either<Failure, void>> deleteCustomer(String customerId);

  /// Delete customer and user account
  Future<Either<Failure, void>> deleteCustomerAndAccount(String customerId);
}