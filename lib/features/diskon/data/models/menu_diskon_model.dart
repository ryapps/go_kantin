import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/diskon/domain/entities/menu_diskon.dart';

class MenuDiskonModel extends Equatable {
  final String id;
  final String menuId; // ref to Menu
  final String diskonId; // ref to Diskon

  const MenuDiskonModel({
    required this.id,
    required this.menuId,
    required this.diskonId,
  });

  factory MenuDiskonModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return MenuDiskonModel(
      id: snapshot.id,
      menuId: data['menuId'] ?? '',
      diskonId: data['diskonId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'menuId': menuId,
      'diskonId': diskonId,
    };
  }

  factory MenuDiskonModel.fromJson(Map<String, dynamic> json) {
    return MenuDiskonModel(
      id: json['id'] ?? '',
      menuId: json['menuId'] ?? '',
      diskonId: json['diskonId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuId': menuId,
      'diskonId': diskonId,
    };
  }

  factory MenuDiskonModel.fromEntity(MenuDiskon entity) {
    return MenuDiskonModel(
      id: entity.id,
      menuId: entity.menuId,
      diskonId: entity.diskonId,
    );
  }

  MenuDiskon toEntity() {
    return MenuDiskon(
      id: id,
      menuId: menuId,
      diskonId: diskonId,
    );
  }

  MenuDiskonModel copyWith({
    String? id,
    String? menuId,
    String? diskonId,
  }) {
    return MenuDiskonModel(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      diskonId: diskonId ?? this.diskonId,
    );
  }

  @override
  List<Object?> get props => [id, menuId, diskonId];
}