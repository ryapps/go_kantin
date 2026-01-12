import 'package:equatable/equatable.dart';

class Siswa extends Equatable {
  final String id;
  final String userId; // ref to User
  final String namaSiswa;
  final String alamat;
  final String telp;
  final String foto; // profile photo URL
  final int dailyOrderCount;
  final String lastOrderDate; // YYYY-MM-DD

  const Siswa({
    required this.id,
    required this.userId,
    required this.namaSiswa,
    required this.alamat,
    required this.telp,
    required this.foto,
    this.dailyOrderCount = 0,
    required this.lastOrderDate,
  });

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