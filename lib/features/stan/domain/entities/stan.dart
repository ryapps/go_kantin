import 'package:equatable/equatable.dart';

class Stan extends Equatable {
  final String id;
  final String userId; // stall owner's user ID
  final String namaStan;
  final String namaPemilik; // owner name
  final String telp;
  final bool isActive;
  final DateTime createdAt;

  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String openTime;
  final String closeTime;
  final List<String> categories;
  final String location;

  const Stan({
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

  Stan copyWith({
    String? id,
    String? userId,
    String? namaStan,
    String? namaPemilik,
    String? telp,
    bool? isActive,
    DateTime? createdAt,
    String? description,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? openTime,
    String? closeTime,
    List<String>? categories,
    String? location,
  }) {
    return Stan(
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
