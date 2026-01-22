import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';

class MenuModel extends Equatable {
  final String id;
  final String stanId; // ref to Stan
  final String stanName; // denormalized
  final String namaItem;
  final double harga;
  final String jenis; // 'makanan' | 'minuman'
  final String foto; // image URL
  final String deskripsi;
  final bool isAvailable;
  final Timestamp createdAt;

  const MenuModel({
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

  factory MenuModel.fromFirestore(
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

    return MenuModel(
      id: snapshot.id,
      stanId: data['stanId'] ?? '',
      stanName: data['stanName'] ?? '',
      namaItem: data['namaItem'] ?? '',
      harga: (data['harga'] ?? 0).toDouble(),
      jenis: data['jenis'] ?? '',
      foto: data['foto'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'stanId': stanId,
      'stanName': stanName,
      'namaItem': namaItem,
      'harga': harga,
      'jenis': jenis,
      'foto': foto,
      'deskripsi': deskripsi,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] ?? '',
      stanId: json['stanId'] ?? '',
      stanName: json['stanName'] ?? '',
      namaItem: json['namaItem'] ?? '',
      harga: (json['harga'] ?? 0).toDouble(),
      jenis: json['jenis'] ?? '',
      foto: json['foto'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      createdAt: json['createdAt'] != null
          ? Timestamp.fromDate(DateTime.parse(json['createdAt']))
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stanId': stanId,
      'stanName': stanName,
      'namaItem': namaItem,
      'harga': harga,
      'jenis': jenis,
      'foto': foto,
      'deskripsi': deskripsi,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toDate().toIso8601String(),
    };
  }

  factory MenuModel.fromEntity(Menu entity) {
    return MenuModel(
      id: entity.id,
      stanId: entity.stanId,
      stanName: entity.stanName,
      namaItem: entity.namaItem,
      harga: entity.harga,
      jenis: entity.jenis,
      foto: entity.foto,
      deskripsi: entity.deskripsi,
      isAvailable: entity.isAvailable,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  Menu toEntity() {
    return Menu(
      id: id,
      stanId: stanId,
      stanName: stanName,
      namaItem: namaItem,
      harga: harga,
      jenis: jenis,
      foto: foto,
      deskripsi: deskripsi,
      isAvailable: isAvailable,
      createdAt: createdAt.toDate(),
    );
  }

  MenuModel copyWith({
    String? id,
    String? stanId,
    String? stanName,
    String? namaItem,
    double? harga,
    String? jenis,
    String? foto,
    String? deskripsi,
    bool? isAvailable,
    Timestamp? createdAt,
  }) {
    return MenuModel(
      id: id ?? this.id,
      stanId: stanId ?? this.stanId,
      stanName: stanName ?? this.stanName,
      namaItem: namaItem ?? this.namaItem,
      harga: harga ?? this.harga,
      jenis: jenis ?? this.jenis,
      foto: foto ?? this.foto,
      deskripsi: deskripsi ?? this.deskripsi,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
