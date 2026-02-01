import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class DashboardLoaded extends DashboardState {
  final int newOrders;
  final int inProcess;
  final int completed;
  final double revenue;
  final int totalCustomers;
  final int totalMenuItems;
  final List<String> topSellingItems;
  final Map<String, dynamic> monthlyStats;

  const DashboardLoaded({
    required this.newOrders,
    required this.inProcess,
    required this.completed,
    required this.revenue,
    this.totalCustomers = 0,
    this.totalMenuItems = 0,
    this.topSellingItems = const [],
    this.monthlyStats = const {},
  });

  @override
  List<Object?> get props => [
    newOrders,
    inProcess,
    completed,
    revenue,
    totalCustomers,
    totalMenuItems,
    topSellingItems,
    monthlyStats,
  ];

  DashboardLoaded copyWith({
    int? newOrders,
    int? inProcess,
    int? completed,
    double? revenue,
    int? totalCustomers,
    int? totalMenuItems,
    List<String>? topSellingItems,
    Map<String, dynamic>? monthlyStats,
  }) {
    return DashboardLoaded(
      newOrders: newOrders ?? this.newOrders,
      inProcess: inProcess ?? this.inProcess,
      completed: completed ?? this.completed,
      revenue: revenue ?? this.revenue,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalMenuItems: totalMenuItems ?? this.totalMenuItems,
      topSellingItems: topSellingItems ?? this.topSellingItems,
      monthlyStats: monthlyStats ?? this.monthlyStats,
    );
  }
}
