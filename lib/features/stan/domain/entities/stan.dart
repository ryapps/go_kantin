import 'package:equatable/equatable.dart';

class Stan extends Equatable {
  final String id;
  final String userId; // stall owner's user ID
  final String namaStan;
  final String namaPemilik; // owner name
  final String telp;
  final bool isActive;
  final DateTime createdAt;

  const Stan({
    required this.id,
    required this.userId,
    required this.namaStan,
    required this.namaPemilik,
    required this.telp,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    namaStan,
    namaPemilik,
    telp,
    isActive,
    createdAt,
  ];
}