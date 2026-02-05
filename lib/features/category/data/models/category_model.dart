import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.imageUrl,
    super.order,
    super.isActive,
  });

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return CategoryModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '📦',
      imageUrl: data['imageUrl'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      imageUrl: json['imageUrl'] as String,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      imageUrl: category.imageUrl,
      order: category.order,
      isActive: category.isActive,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      imageUrl: imageUrl,
      order: order,
      isActive: isActive,
    );
  }
}
