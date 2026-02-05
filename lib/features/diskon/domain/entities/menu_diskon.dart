import 'package:equatable/equatable.dart';

/// Junction table untuk relasi many-to-many antara Menu dan Diskon
class MenuDiskon extends Equatable {
  final String id;
  final String menuId; // ref to Menu
  final String diskonId; // ref to Diskon
  final DateTime createdAt;

  const MenuDiskon({
    required this.id,
    required this.menuId,
    required this.diskonId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, menuId, diskonId, createdAt];
}
