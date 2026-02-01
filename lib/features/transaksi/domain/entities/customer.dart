import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String role;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.totalOrders,
    required this.totalSpent,
    this.lastOrderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.empty(String userId) {
    return Customer(
      id: '',
      userId: userId,
      name: '',
      email: '',
      role: '',
      totalOrders: 0,
      totalSpent: 0.0,
      lastOrderDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Customer copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? role,
    int? totalOrders,
    double? totalSpent,
    DateTime? lastOrderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}