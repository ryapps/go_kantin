import 'package:equatable/equatable.dart';

abstract class CustomerManagementEvent extends Equatable {
  const CustomerManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerManagementEvent {
  final String stanId;

  const LoadCustomers(this.stanId);

  @override
  List<Object?> get props => [stanId];
}

class SearchCustomers extends CustomerManagementEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadCustomerDetails extends CustomerManagementEvent {
  final String siswaId;
  final String stanId;

  const LoadCustomerDetails(this.siswaId, this.stanId);

  @override
  List<Object?> get props => [siswaId, stanId];
}

class CreateCustomer extends CustomerManagementEvent {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String password;

  const CreateCustomer({
    this.userId = '', // Default to empty string, will be auto-generated
    required this.name,
    required this.email,
    required this.role,
    required this.password,
  });

  @override
  List<Object?> get props => [userId, name, email, role, password];
}

class UpdateCustomer extends CustomerManagementEvent {
  final String customerId;
  final String? name;
  final String? email;

  const UpdateCustomer({
    required this.customerId,
    this.name,
    this.email,
  });

  @override
  List<Object?> get props => [customerId, name, email];
}

class DeleteCustomer extends CustomerManagementEvent {
  final String customerId;

  const DeleteCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
