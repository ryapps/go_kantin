import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/admin/domain/entities/dashboard_data.dart';

class DashboardDataModel extends Equatable {
  final String id;
  final String stanId;
  final int newOrders;
  final int inProcess;
  final int completed;
  final double revenue;
  final int totalCustomers;
  final int totalMenuItems;
  final List<String> topSellingItems;
  final Map<String, dynamic> monthlyStats;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DashboardDataModel({
    required this.id,
    required this.stanId,
    required this.newOrders,
    required this.inProcess,
    required this.completed,
    required this.revenue,
    this.totalCustomers = 0,
    this.totalMenuItems = 0,
    this.topSellingItems = const [],
    this.monthlyStats = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardDataModel.fromEntity(DashboardData entity) {
    return DashboardDataModel(
      id: entity.id,
      stanId: entity.stanId,
      newOrders: entity.newOrders,
      inProcess: entity.inProcess,
      completed: entity.completed,
      revenue: entity.revenue,
      totalCustomers: entity.totalCustomers,
      totalMenuItems: entity.totalMenuItems,
      topSellingItems: entity.topSellingItems,
      monthlyStats: entity.monthlyStats,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory DashboardDataModel.fromFirestore(
    Map<String, dynamic> snapshot,
    String id,
  ) {
    return DashboardDataModel(
      id: id,
      stanId: snapshot['stanId'] ?? '',
      newOrders: snapshot['newOrders']?.toInt() ?? 0,
      inProcess: snapshot['inProcess']?.toInt() ?? 0,
      completed: snapshot['completed']?.toInt() ?? 0,
      revenue: (snapshot['revenue'] as num?)?.toDouble() ?? 0.0,
      totalCustomers: snapshot['totalCustomers']?.toInt() ?? 0,
      totalMenuItems: snapshot['totalMenuItems']?.toInt() ?? 0,
      topSellingItems: List<String>.from(snapshot['topSellingItems'] ?? []),
      monthlyStats: Map<String, dynamic>.from(snapshot['monthlyStats'] ?? {}),
      createdAt: (snapshot['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (snapshot['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'stanId': stanId,
      'newOrders': newOrders,
      'inProcess': inProcess,
      'completed': completed,
      'revenue': revenue,
      'totalCustomers': totalCustomers,
      'totalMenuItems': totalMenuItems,
      'topSellingItems': topSellingItems,
      'monthlyStats': monthlyStats,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DashboardData toEntity() {
    return DashboardData(
      id: id,
      stanId: stanId,
      newOrders: newOrders,
      inProcess: inProcess,
      completed: completed,
      revenue: revenue,
      totalCustomers: totalCustomers,
      totalMenuItems: totalMenuItems,
      topSellingItems: topSellingItems,
      monthlyStats: monthlyStats,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory DashboardDataModel.empty(String stanId) {
    return DashboardDataModel(
      id: '',
      stanId: stanId,
      newOrders: 0,
      inProcess: 0,
      completed: 0,
      revenue: 0.0,
      totalCustomers: 0,
      totalMenuItems: 0,
      topSellingItems: [],
      monthlyStats: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    stanId,
    newOrders,
    inProcess,
    completed,
    revenue,
    totalCustomers,
    totalMenuItems,
    topSellingItems,
    monthlyStats,
    createdAt,
    updatedAt,
  ];
}