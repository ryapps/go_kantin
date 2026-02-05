import 'package:hive/hive.dart';

part 'favorite_stan_model.g.dart';

@HiveType(typeId: 0)
class FavoriteStanModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String namaStan;

  @HiveField(2)
  final String namaPemilik;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final DateTime createdAt;

  FavoriteStanModel({
    required this.id,
    required this.namaStan,
    required this.namaPemilik,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  // Convert from Stan entity
  factory FavoriteStanModel.fromStan({
    required String id,
    required String namaStan,
    required String namaPemilik,
    required String description,
    required String imageUrl,
  }) {
    return FavoriteStanModel(
      id: id,
      namaStan: namaStan,
      namaPemilik: namaPemilik,
      description: description,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaStan': namaStan,
      'namaPemilik': namaPemilik,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
