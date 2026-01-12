import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/auth/domain/entities/user.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String role; // 'siswa' | 'admin_stan' | 'super_admin'
  final Timestamp createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return UserModel(
      id: snapshot.id,
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      createdAt: data['createdAt'] ?? FieldValue.serverTimestamp() as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'role': role,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['createdAt'] != null 
          ? Timestamp.fromDate(DateTime.parse(json['createdAt'])) 
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'createdAt': createdAt.toDate().toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      role: entity.role,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      role: role,
      createdAt: createdAt.toDate(),
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? role,
    Timestamp? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, username, role, createdAt];
}