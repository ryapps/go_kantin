import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';

class StanModel extends Equatable {
  final String id;
  final String userId; // stall owner's user ID
  final String namaStan;
  final String namaPemilik; // owner name
  final String telp;
  final bool isActive;
  final Timestamp createdAt;

  const StanModel({
    required this.id,
    required this.userId,
    required this.namaStan,
    required this.namaPemilik,
    required this.telp,
    this.isActive = true,
    required this.createdAt,
  });

  factory StanModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return StanModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      namaStan: data['namaStan'] ?? '',
      namaPemilik: data['namaPemilik'] ?? '',
      telp: data['telp'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] ?? FieldValue.serverTimestamp() as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'namaStan': namaStan,
      'namaPemilik': namaPemilik,
      'telp': telp,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  factory StanModel.fromJson(Map<String, dynamic> json) {
    return StanModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      namaStan: json['namaStan'] ?? '',
      namaPemilik: json['namaPemilik'] ?? '',
      telp: json['telp'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? Timestamp.fromDate(DateTime.parse(json['createdAt'])) 
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'namaStan': namaStan,
      'namaPemilik': namaPemilik,
      'telp': telp,
      'isActive': isActive,
      'createdAt': createdAt.toDate().toIso8601String(),
    };
  }

  factory StanModel.fromEntity(Stan entity) {
    return StanModel(
      id: entity.id,
      userId: entity.userId,
      namaStan: entity.namaStan,
      namaPemilik: entity.namaPemilik,
      telp: entity.telp,
      isActive: entity.isActive,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  Stan toEntity() {
    return Stan(
      id: id,
      userId: userId,
      namaStan: namaStan,
      namaPemilik: namaPemilik,
      telp: telp,
      isActive: isActive,
      createdAt: createdAt.toDate(),
    );
  }

  StanModel copyWith({
    String? id,
    String? userId,
    String? namaStan,
    String? namaPemilik,
    String? telp,
    bool? isActive,
    Timestamp? createdAt,
  }) {
    return StanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaStan: namaStan ?? this.namaStan,
      namaPemilik: namaPemilik ?? this.namaPemilik,
      telp: telp ?? this.telp,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    namaStan,
    namaPemilik,
    telp,
    isActive,
    createdAt,
  ];
}