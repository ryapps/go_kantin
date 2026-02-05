import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final int order; // untuk sorting
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    this.order = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, icon, imageUrl, order, isActive];

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? imageUrl,
    int? order,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}
