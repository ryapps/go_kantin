import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
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

  const DashboardData({
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

  factory DashboardData.empty(String stanId) {
    return DashboardData(
      id: '',
      stanId: stanId,
      newOrders: 0,
      inProcess: 0,
      completed: 0,
      revenue: 0.0,
      totalCustomers: 0,
      totalMenuItems: 0,
      topSellingItems: const [],
      monthlyStats: const {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  DashboardData copyWith({
    String? id,
    String? stanId,
    int? newOrders,
    int? inProcess,
    int? completed,
    double? revenue,
    int? totalCustomers,
    int? totalMenuItems,
    List<String>? topSellingItems,
    Map<String, dynamic>? monthlyStats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DashboardData(
      id: id ?? this.id,
      stanId: stanId ?? this.stanId,
      newOrders: newOrders ?? this.newOrders,
      inProcess: inProcess ?? this.inProcess,
      completed: completed ?? this.completed,
      revenue: revenue ?? this.revenue,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalMenuItems: totalMenuItems ?? this.totalMenuItems,
      topSellingItems: topSellingItems ?? this.topSellingItems,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  factory DashboardData.fromFirestore(
    Map<String, dynamic> snapshot,
    String id,
  ) {
    return DashboardData(
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