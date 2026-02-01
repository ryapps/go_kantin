import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';

class CustomerInfo {
  final String siswaId;
  final String siswaName;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;

  const CustomerInfo({
    required this.siswaId,
    required this.siswaName,
    required this.totalOrders,
    required this.totalSpent,
    this.lastOrderDate,
  });
}

abstract class CustomerManagementState extends Equatable {
  const CustomerManagementState();

  @override
  List<Object?> get props => [];
}

class CustomerManagementInitial extends CustomerManagementState {}

class CustomerManagementLoading extends CustomerManagementState {}

class CustomersLoaded extends CustomerManagementState {
  final List<CustomerInfo> customers;
  final List<CustomerInfo> filteredCustomers;
  final String? searchQuery;

  const CustomersLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [customers, filteredCustomers, searchQuery];

  CustomersLoaded copyWith({
    List<CustomerInfo>? customers,
    List<CustomerInfo>? filteredCustomers,
    String? searchQuery,
  }) {
    return CustomersLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerDetailsLoading extends CustomerManagementState {
  final CustomerInfo customer;

  const CustomerDetailsLoading(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerDetailsLoaded extends CustomerManagementState {
  final CustomerInfo customer;
  final List<Transaksi> transactions;

  const CustomerDetailsLoaded({
    required this.customer,
    required this.transactions,
  });

  @override
  List<Object?> get props => [customer, transactions];
}

class CustomerCreated extends CustomerManagementState {
  final CustomerInfo customer;

  const CustomerCreated(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerUpdated extends CustomerManagementState {
  final CustomerInfo customer;

  const CustomerUpdated(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerDeleted extends CustomerManagementState {
  final String customerId;

  const CustomerDeleted(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class CustomerManagementError extends CustomerManagementState {
  final String message;

  const CustomerManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
