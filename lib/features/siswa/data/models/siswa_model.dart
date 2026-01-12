import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/siswa/domain/entities/siswa.dart';

class SiswaModel extends Equatable {
  final String id;
  final String userId; // ref to User
  final String namaSiswa;
  final String alamat;
  final String telp;
  final String foto; // profile photo URL
  final int dailyOrderCount;
  final String lastOrderDate; // YYYY-MM-DD

  const SiswaModel({
    required this.id,
    required this.userId,
    required this.namaSiswa,
    required this.alamat,
    required this.telp,
    required this.foto,
    this.dailyOrderCount = 0,
    required this.lastOrderDate,
  });

  factory SiswaModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return SiswaModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      namaSiswa: data['namaSiswa'] ?? '',
      alamat: data['alamat'] ?? '',
      telp: data['telp'] ?? '',
      foto: data['foto'] ?? '',
      dailyOrderCount: data['dailyOrderCount']?.toInt() ?? 0,
      lastOrderDate: data['lastOrderDate'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'namaSiswa': namaSiswa,
      'alamat': alamat,
      'telp': telp,
      'foto': foto,
      'dailyOrderCount': dailyOrderCount,
      'lastOrderDate': lastOrderDate,
    };
  }

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    return SiswaModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      namaSiswa: json['namaSiswa'] ?? '',
      alamat: json['alamat'] ?? '',
      telp: json['telp'] ?? '',
      foto: json['foto'] ?? '',
      dailyOrderCount: json['dailyOrderCount']?.toInt() ?? 0,
      lastOrderDate: json['lastOrderDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'namaSiswa': namaSiswa,
      'alamat': alamat,
      'telp': telp,
      'foto': foto,
      'dailyOrderCount': dailyOrderCount,
      'lastOrderDate': lastOrderDate,
    };
  }

  factory SiswaModel.fromEntity(Siswa entity) {
    return SiswaModel(
      id: entity.id,
      userId: entity.userId,
      namaSiswa: entity.namaSiswa,
      alamat: entity.alamat,
      telp: entity.telp,
      foto: entity.foto,
      dailyOrderCount: entity.dailyOrderCount,
      lastOrderDate: entity.lastOrderDate,
    );
  }

  Siswa toEntity() {
    return Siswa(
      id: id,
      userId: userId,
      namaSiswa: namaSiswa,
      alamat: alamat,
      telp: telp,
      foto: foto,
      dailyOrderCount: dailyOrderCount,
      lastOrderDate: lastOrderDate,
    );
  }

  SiswaModel copyWith({
    String? id,
    String? userId,
    String? namaSiswa,
    String? alamat,
    String? telp,
    String? foto,
    int? dailyOrderCount,
    String? lastOrderDate,
  }) {
    return SiswaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaSiswa: namaSiswa ?? this.namaSiswa,
      alamat: alamat ?? this.alamat,
      telp: telp ?? this.telp,
      foto: foto ?? this.foto,
      dailyOrderCount: dailyOrderCount ?? this.dailyOrderCount,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
    );
  }

  // Business Logic: Daily order limit tracking (100/day)
  bool get hasReachedDailyLimit => dailyOrderCount >= 100;

  @override
  List<Object?> get props => [
    id,
    userId,
    namaSiswa,
    alamat,
    telp,
    foto,
    dailyOrderCount,
    lastOrderDate,
  ];
}