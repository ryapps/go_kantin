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
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String openTime;
  final String closeTime;
  final List<String> categories;
  final String location;

  const StanModel({
    required this.id,
    required this.userId,
    required this.namaStan,
    required this.namaPemilik,
    required this.telp,
    this.isActive = true,
    required this.createdAt,
    this.description = '',
    this.imageUrl = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.openTime = '',
    this.closeTime = '',
    this.categories = const [],
    this.location = '',
  });

  factory StanModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    Timestamp parseTimestamp(dynamic value) {
      if (value is Timestamp) return value;
      if (value is String && value.isNotEmpty) {
        return Timestamp.fromDate(DateTime.parse(value));
      }
      if (value is int) {
        return Timestamp.fromMillisecondsSinceEpoch(value);
      }
      return Timestamp.now();
    }

    return StanModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      namaStan: data['namaStan'] ?? '',
      namaPemilik: data['namaPemilik'] ?? '',
      telp: data['telp'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: parseTimestamp(data['createdAt']),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount']?.toInt() ?? 0,
      openTime: data['openTime'] ?? '',
      closeTime: data['closeTime'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      location: data['location'] ?? '',
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
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'openTime': openTime,
      'closeTime': closeTime,
      'categories': categories,
      'location': location,
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
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount']?.toInt() ?? 0,
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      location: json['location'] ?? '',
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
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'openTime': openTime,
      'closeTime': closeTime,
      'categories': categories,
      'location': location,
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
      description: entity.description,
      imageUrl: entity.imageUrl,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      openTime: entity.openTime,
      closeTime: entity.closeTime,
      categories: entity.categories,
      location: entity.location,
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
      description: description,
      imageUrl: imageUrl,
      rating: rating,
      reviewCount: reviewCount,
      openTime: openTime,
      closeTime: closeTime,
      categories: categories,
      location: location,
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
    String? description,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? openTime,
    String? closeTime,
    List<String>? categories,
    String? location,
  }) {
    return StanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaStan: namaStan ?? this.namaStan,
      namaPemilik: namaPemilik ?? this.namaPemilik,
      telp: telp ?? this.telp,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      categories: categories ?? this.categories,
      location: location ?? this.location,
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
    description,
    imageUrl,
    rating,
    reviewCount,
    openTime,
    closeTime,
    categories,
    location,
  ];
}
