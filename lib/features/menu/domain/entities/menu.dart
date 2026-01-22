import 'package:equatable/equatable.dart';

class Menu extends Equatable {
  final String id;
  final String stanId; // ref to Stan
  final String stanName; // denormalized
  final String namaItem;
  final double harga;
  final String jenis; // 'makanan' | 'minuman'
  final String foto; // image URL
  final String deskripsi;
  final bool isAvailable;
  final DateTime createdAt;

  const Menu({
    required this.id,
    required this.stanId,
    required this.stanName,
    required this.namaItem,
    required this.harga,
    required this.jenis,
    required this.foto,
    required this.deskripsi,
    this.isAvailable = true,
    required this.createdAt,
  });

  bool get isMakanan => jenis == 'makanan';
  bool get isMinuman => jenis == 'minuman';

  @override
  List<Object?> get props => [
    id,
    stanId,
    stanName,
    namaItem,
    harga,
    jenis,
    foto,
    deskripsi,
    isAvailable,
    createdAt,
  ];
}
