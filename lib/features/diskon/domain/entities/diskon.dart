import 'package:equatable/equatable.dart';

class Diskon extends Equatable {
  final String id;
  final String stanId; // Diskon berlaku per kantin
  final String namaDiskon;
  final double persentaseDiskon; // 0-100
  final DateTime tanggalAwal;
  final DateTime tanggalAkhir;
  final bool isActive;
  final DateTime createdAt;

  const Diskon({
    required this.id,
    required this.stanId,
    required this.namaDiskon,
    required this.persentaseDiskon,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(tanggalAwal) && now.isBefore(tanggalAkhir);
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(tanggalAkhir);
  }

  Diskon copyWith({
    String? id,
    String? stanId,
    String? namaDiskon,
    double? persentaseDiskon,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Diskon(
      id: id ?? this.id,
      stanId: stanId ?? this.stanId,
      namaDiskon: namaDiskon ?? this.namaDiskon,
      persentaseDiskon: persentaseDiskon ?? this.persentaseDiskon,
      tanggalAwal: tanggalAwal ?? this.tanggalAwal,
      tanggalAkhir: tanggalAkhir ?? this.tanggalAkhir,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    stanId,
    namaDiskon,
    persentaseDiskon,
    tanggalAwal,
    tanggalAkhir,
    isActive,
    createdAt,
  ];
}
