import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';

abstract class OrderManagementState extends Equatable {
  const OrderManagementState();

  @override
  List<Object?> get props => [];
}

class OrderManagementInitial extends OrderManagementState {}

class OrderManagementLoading extends OrderManagementState {}

class OrderManagementLoaded extends OrderManagementState {
  final List<Transaksi> orders;
  final List<Transaksi> filteredOrders;
  final String? statusFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? monthFilter;
  final int? yearFilter;
  final String? searchQuery;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;

  const OrderManagementLoaded({
    required this.orders,
    required this.filteredOrders,
    this.statusFilter,
    this.startDate,
    this.endDate,
    this.monthFilter,
    this.yearFilter,
    this.searchQuery,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
  });

  @override
  List<Object?> get props => [
    orders,
    filteredOrders,
    statusFilter,
    startDate,
    endDate,
    monthFilter,
    yearFilter,
    searchQuery,
    isUpdating,
    errorMessage,
    successMessage,
  ];

  OrderManagementLoaded copyWith({
    List<Transaksi>? orders,
    List<Transaksi>? filteredOrders,
    String? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
    int? monthFilter,
    int? yearFilter,
    String? searchQuery,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
  }) {
    return OrderManagementLoaded(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      statusFilter: statusFilter ?? this.statusFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      monthFilter: monthFilter ?? this.monthFilter,
      yearFilter: yearFilter ?? this.yearFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  Map<String, int> get statusCounts {
    return {
      'belum_dikonfirm': orders
          .where((o) => o.status == 'belum_dikonfirm')
          .length,
      'dimasak': orders.where((o) => o.status == 'dimasak').length,
      'diantar': orders.where((o) => o.status == 'diantar').length,
      'sampai': orders.where((o) => o.status == 'sampai').length,
    };
  }
}

class OrderManagementUpdating extends OrderManagementState {
  final List<Transaksi> orders;

  const OrderManagementUpdating(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderManagementSuccess extends OrderManagementState {
  final List<Transaksi> orders;
  final String message;

  const OrderManagementSuccess(this.orders, this.message);

  @override
  List<Object?> get props => [orders, message];
}

class OrderManagementError extends OrderManagementState {
  final String message;

  const OrderManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
