import 'package:equatable/equatable.dart';

class Diskon extends Equatable{
  final String id;
  final String namaDiskon;
  final double persentaseDiskon; // 0-100
  final DateTime tanggalAwal;
  final DateTime tanggalAkhir;
  final bool isActive;
  final DateTime createdAt;

  const Diskon({
    required this.id,
    required this.namaDiskon,
    required this.persentaseDiskon,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(tanggalAwal) && 
           now.isBefore(tanggalAkhir);
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(tanggalAkhir);
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