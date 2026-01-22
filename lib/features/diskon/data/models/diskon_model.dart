import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/diskon/domain/entities/menu_diskon.dart';

class DiskonModel extends Equatable {
  final String id;
  final String namaDiskon;
  final double persentaseDiskon; // 0-100
  final Timestamp tanggalAwal;
  final Timestamp tanggalAkhir;
  final bool isActive;
  final Timestamp createdAt;

  const DiskonModel({
    required this.id,
    required this.namaDiskon,
    required this.persentaseDiskon,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    this.isActive = true,
    required this.createdAt,
  });

  factory DiskonModel.fromFirestore(
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

    return DiskonModel(
      id: snapshot.id,
      namaDiskon: data['namaDiskon'] ?? '',
      persentaseDiskon: (data['persentaseDiskon'] ?? 0).toDouble(),
      tanggalAwal: parseTimestamp(data['tanggalAwal']),
      tanggalAkhir: parseTimestamp(data['tanggalAkhir']),
      isActive: data['isActive'] ?? true,
      createdAt: parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'namaDiskon': namaDiskon,
      'persentaseDiskon': persentaseDiskon,
      'tanggalAwal': tanggalAwal,
      'tanggalAkhir': tanggalAkhir,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  factory DiskonModel.fromJson(Map<String, dynamic> json) {
    return DiskonModel(
      id: json['id'] ?? '',
      namaDiskon: json['namaDiskon'] ?? '',
      persentaseDiskon: (json['persentaseDiskon'] ?? 0).toDouble(),
      tanggalAwal: json['tanggalAwal'] != null
          ? Timestamp.fromDate(DateTime.parse(json['tanggalAwal']))
          : Timestamp.now(),
      tanggalAkhir: json['tanggalAkhir'] != null
          ? Timestamp.fromDate(DateTime.parse(json['tanggalAkhir']))
          : Timestamp.now(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? Timestamp.fromDate(DateTime.parse(json['createdAt']))
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaDiskon': namaDiskon,
      'persentaseDiskon': persentaseDiskon,
      'tanggalAwal': tanggalAwal.toDate().toIso8601String(),
      'tanggalAkhir': tanggalAkhir.toDate().toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toDate().toIso8601String(),
    };
  }

  factory DiskonModel.fromEntity(Diskon entity) {
    return DiskonModel(
      id: entity.id,
      namaDiskon: entity.namaDiskon,
      persentaseDiskon: entity.persentaseDiskon,
      tanggalAwal: Timestamp.fromDate(entity.tanggalAwal),
      tanggalAkhir: Timestamp.fromDate(entity.tanggalAkhir),
      isActive: entity.isActive,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  Diskon toEntity() {
    return Diskon(
      id: id,
      namaDiskon: namaDiskon,
      persentaseDiskon: persentaseDiskon,
      tanggalAwal: tanggalAwal.toDate(),
      tanggalAkhir: tanggalAkhir.toDate(),
      isActive: isActive,
      createdAt: createdAt.toDate(),
    );
  }

  DiskonModel copyWith({
    String? id,
    String? namaDiskon,
    double? persentaseDiskon,
    Timestamp? tanggalAwal,
    Timestamp? tanggalAkhir,
    bool? isActive,
    Timestamp? createdAt,
  }) {
    return DiskonModel(
      id: id ?? this.id,
      namaDiskon: namaDiskon ?? this.namaDiskon,
      persentaseDiskon: persentaseDiskon ?? this.persentaseDiskon,
      tanggalAwal: tanggalAwal ?? this.tanggalAwal,
      tanggalAkhir: tanggalAkhir ?? this.tanggalAkhir,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(tanggalAwal.toDate()) &&
        now.isBefore(tanggalAkhir.toDate());
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(tanggalAkhir.toDate());
  }

  @override
  List<Object?> get props => [
    id,
    namaDiskon,
    persentaseDiskon,
    tanggalAwal,
    tanggalAkhir,
    isActive,
    createdAt,
  ];
}
