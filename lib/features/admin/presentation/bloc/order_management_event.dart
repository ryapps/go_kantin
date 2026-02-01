import 'package:equatable/equatable.dart';

abstract class OrderManagementEvent extends Equatable {
  const OrderManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderManagementEvent {
  final String stanId;

  const LoadOrders(this.stanId);

  @override
  List<Object?> get props => [stanId];
}

class UpdateOrderStatus extends OrderManagementEvent {
  final String transaksiId;
  final String newStatus;

  const UpdateOrderStatus({required this.transaksiId, required this.newStatus});

  @override
  List<Object?> get props => [transaksiId, newStatus];
}

class FilterOrdersByStatus extends OrderManagementEvent {
  final String? status; // null = all orders

  const FilterOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class FilterOrdersByDate extends OrderManagementEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterOrdersByDate({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class FilterOrdersByMonth extends OrderManagementEvent {
  final String stanId;
  final int month;
  final int year;

  const FilterOrdersByMonth(this.stanId, this.month, this.year);

  @override
  List<Object?> get props => [stanId, month, year];
}

class SearchOrders extends OrderManagementEvent {
  final String query;

  const SearchOrders(this.query);

  @override
  List<Object?> get props => [query];
}

class RefreshOrders extends OrderManagementEvent {
  final String stanId;

  const RefreshOrders(this.stanId);

  @override
  List<Object?> get props => [stanId];
}
