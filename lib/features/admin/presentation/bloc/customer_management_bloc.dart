import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/admin/domain/usecases/get_all_customers.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_state.dart';
import 'package:kantin_app/features/transaksi/data/repositories/customer_repository.dart';
import 'package:kantin_app/features/transaksi/data/repositories/transaksi_repository.dart';

class CustomerManagementBloc
    extends Bloc<CustomerManagementEvent, CustomerManagementState> {
  final GetAllCustomers getAllCustomers;
  final TransaksiRepository transaksiRepository;
  final CustomerRepository customerRepository;
  String? _currentStanId; // Store the current stanId

  CustomerManagementBloc({
    required this.getAllCustomers,
    required this.transaksiRepository,
    required this.customerRepository,
  }) : super(CustomerManagementInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<LoadCustomerDetails>(_onLoadCustomerDetails);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerManagementState> emit,
  ) async {
    _currentStanId = event.stanId; // Store the stanId
    emit(CustomerManagementLoading());

    // First, get all customers from the customer collection
    final customerResult = await getAllCustomers();

    if (customerResult.isLeft()) {
      final failure = customerResult.fold((l) => l, (r) => null);
      emit(CustomerManagementError(failure!.message));
      return;
    }

    final customersRaw = customerResult.fold((l) => null, (r) => r);
    if (customersRaw == null) {
      emit(CustomerManagementError("Failed to load customers."));
      return;
    }

    // Map customers with their information from the customer collection
    final customers = customersRaw.map<CustomerInfo>((data) {
      return CustomerInfo(
        siswaId: data['userId'] ?? data['uid'] ?? '',
        siswaName: data['name'] ?? data['username'] ?? '',
        totalOrders: data['totalOrders']?.toInt() ?? 0,
        totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
        lastOrderDate: (data['lastOrderDate'] as Timestamp?)?.toDate(),
      );
    }).toList();

    emit(CustomersLoaded(customers: customers, filteredCustomers: customers));
  }

  void _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! CustomersLoaded) return;

    final filteredCustomers = event.query.isEmpty
        ? currentState.customers
        : currentState.customers
              .where(
                (customer) => customer.siswaName.toLowerCase().contains(
                  event.query.toLowerCase(),
                ),
              )
              .toList();

    emit(
      CustomersLoaded(
        customers: currentState.customers,
        filteredCustomers: filteredCustomers,
        searchQuery: event.query,
      ),
    );
  }

  Future<void> _onLoadCustomerDetails(
    LoadCustomerDetails event,
    Emitter<CustomerManagementState> emit,
  ) async {
    // First, try to get the customer from the current state
    CustomerInfo? customer;

    final currentState = state;
    if (currentState is CustomersLoaded) {
      customer = currentState.customers.firstWhere(
        (c) => c.siswaId == event.siswaId,
        orElse: () => CustomerInfo(
          siswaId: event.siswaId,
          siswaName: 'Pelanggan',
          totalOrders: 0,
          totalSpent: 0.0,
          lastOrderDate: null,
        ),
      );
    } else {
      // If we don't have the loaded state, create a basic customer info
      customer = CustomerInfo(
        siswaId: event.siswaId,
        siswaName: 'Pelanggan',
        totalOrders: 0,
        totalSpent: 0.0,
        lastOrderDate: null,
      );
    }

    emit(CustomerDetailsLoading(customer));

    final result = await transaksiRepository.getTransaksiByStan(event.stanId);

    result.fold(
      (failure) => emit(CustomerManagementError(failure.message)),
      (allTransactions) {
        // Filter transactions for this customer
        final customerTransactions = allTransactions
            .where((t) => t.siswaId == event.siswaId)
            .toList();

        // Sort by date (newest first)
        customerTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        emit(
          CustomerDetailsLoaded(
            customer: customer!,
            transactions: customerTransactions,
          ),
        );
      }
    );
  }

  Future<void> _onCreateCustomer(
    CreateCustomer event,
    Emitter<CustomerManagementState> emit,
  ) async {
    // Notify AuthBloc that admin is creating a customer account
    // This will prevent unwanted auth state changes during customer creation
    // We'll need to access the AuthBloc from here, but since BLoCs shouldn't directly access other BLoCs,
    // we'll need to handle this differently - perhaps by passing the original admin user info

    final result = await customerRepository.createCustomerWithAccount(
      userId: event.userId,
      name: event.name,
      email: event.email,
      role: event.role,
      password: event.password,
    );

    result.fold(
      (failure) => emit(CustomerManagementError(failure.message)),
      (customer) async {
        // Convert to CustomerInfo for UI
        final customerInfo = CustomerInfo(
          siswaId: customer.userId,
          siswaName: customer.name,
          totalOrders: customer.totalOrders,
          totalSpent: customer.totalSpent,
          lastOrderDate: customer.lastOrderDate,
        );
        emit(CustomerCreated(customerInfo));

        // Reload customers to update the list
        if (_currentStanId != null) {
          await _onLoadCustomers(LoadCustomers(_currentStanId!), emit);
        }
      },
    );
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerManagementState> emit,
  ) async {
    final result = await customerRepository.updateCustomerAndProfile(
      customerId: event.customerId,
      name: event.name,
      email: event.email,
    );

    result.fold(
      (failure) => emit(CustomerManagementError(failure.message)),
      (customer) async {
        // Convert to CustomerInfo for UI
        final customerInfo = CustomerInfo(
          siswaId: customer.userId,
          siswaName: customer.name,
          totalOrders: customer.totalOrders,
          totalSpent: customer.totalSpent,
          lastOrderDate: customer.lastOrderDate,
        );
        emit(CustomerUpdated(customerInfo));

        // Reload customers to update the list
        if (_currentStanId != null) {
          await _onLoadCustomers(LoadCustomers(_currentStanId!), emit);
        }
      },
    );
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerManagementState> emit,
  ) async {
    final result = await customerRepository.deleteCustomerAndAccount(event.customerId);

    result.fold(
      (failure) => emit(CustomerManagementError(failure.message)),
      (_) async {
        emit(CustomerDeleted(event.customerId));

        // Reload customers to update the list
        if (_currentStanId != null) {
          await _onLoadCustomers(LoadCustomers(_currentStanId!), emit);
        }
      },
    );
  }
}
