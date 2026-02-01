import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kantin_app/features/transaksi/domain/entities/customer.dart';

class CustomerModel {
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

  CustomerModel({
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

  factory CustomerModel.fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      totalOrders: entity.totalOrders,
      totalSpent: entity.totalSpent,
      lastOrderDate: entity.lastOrderDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory CustomerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return CustomerModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      totalOrders: data['totalOrders']?.toInt() ?? 0,
      totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
      lastOrderDate: (data['lastOrderDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'lastOrderDate': lastOrderDate != null ? Timestamp.fromDate(lastOrderDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Customer toEntity() {
    return Customer(
      id: id,
      userId: userId,
      name: name,
      email: email,
      role: role,
      totalOrders: totalOrders,
      totalSpent: totalSpent,
      lastOrderDate: lastOrderDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}