import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String menuId;
  final String stanId;
  final String stanName;
  final String namaItem;
  final double harga;
  final String foto;
  final int quantity;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.menuId,
    required this.stanId,
    required this.stanName,
    required this.namaItem,
    required this.harga,
    required this.foto,
    required this.quantity,
    required this.addedAt,
  });

  // Calculate total price for this item
  double get totalPrice => harga * quantity;

  // Copy with method for updating quantity
  CartItem copyWith({
    String? id,
    String? menuId,
    String? stanId,
    String? stanName,
    String? namaItem,
    double? harga,
    String? foto,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      stanId: stanId ?? this.stanId,
      stanName: stanName ?? this.stanName,
      namaItem: namaItem ?? this.namaItem,
      harga: harga ?? this.harga,
      foto: foto ?? this.foto,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuId': menuId,
      'stanId': stanId,
      'stanName': stanName,
      'namaItem': namaItem,
      'harga': harga,
      'foto': foto,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // Create from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      menuId: map['menuId'] as String,
      stanId: map['stanId'] as String,
      stanName: map['stanName'] as String,
      namaItem: map['namaItem'] as String,
      harga: (map['harga'] as num).toDouble(),
      foto: map['foto'] as String,
      quantity: map['quantity'] as int,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    menuId,
    stanId,
    stanName,
    namaItem,
    harga,
    foto,
    quantity,
    addedAt,
  ];
}
