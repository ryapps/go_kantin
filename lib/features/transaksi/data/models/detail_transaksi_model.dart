import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';

class DetailTransaksiModel extends Equatable {
  final String id;
  final String transaksiId; // ref to Transaksi
  final String menuId; // ref to Menu
  final String namaMakanan; // denormalized
  final double hargaBeli; // price at time of purchase
  final int qty;
  final double discountAmount;
  final double subtotal; // (hargaBeli × qty) - discountAmount

  const DetailTransaksiModel({
    required this.id,
    required this.transaksiId,
    required this.menuId,
    required this.namaMakanan,
    required this.hargaBeli,
    required this.qty,
    this.discountAmount = 0,
    required this.subtotal,
  });

  factory DetailTransaksiModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return DetailTransaksiModel(
      id: snapshot.id,
      transaksiId: data['transaksiId'] ?? '',
      menuId: data['menuId'] ?? '',
      namaMakanan: data['namaMakanan'] ?? '',
      hargaBeli: (data['hargaBeli'] ?? 0).toDouble(),
      qty: data['qty']?.toInt() ?? 0,
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'transaksiId': transaksiId,
      'menuId': menuId,
      'namaMakanan': namaMakanan,
      'hargaBeli': hargaBeli,
      'qty': qty,
      'discountAmount': discountAmount,
      'subtotal': subtotal,
    };
  }

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      id: json['id'] ?? '',
      transaksiId: json['transaksiId'] ?? '',
      menuId: json['menuId'] ?? '',
      namaMakanan: json['namaMakanan'] ?? '',
      hargaBeli: (json['hargaBeli'] ?? 0).toDouble(),
      qty: json['qty']?.toInt() ?? 0,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaksiId': transaksiId,
      'menuId': menuId,
      'namaMakanan': namaMakanan,
      'hargaBeli': hargaBeli,
      'qty': qty,
      'discountAmount': discountAmount,
      'subtotal': subtotal,
    };
  }

  factory DetailTransaksiModel.fromEntity(DetailTransaksi entity) {
    return DetailTransaksiModel(
      id: entity.id,
      transaksiId: entity.transaksiId,
      menuId: entity.menuId,
      namaMakanan: entity.namaMakanan,
      hargaBeli: entity.hargaBeli,
      qty: entity.qty,
      discountAmount: entity.discountAmount,
      subtotal: entity.subtotal,
    );
  }

  DetailTransaksi toEntity() {
    return DetailTransaksi(
      id: id,
      transaksiId: transaksiId,
      menuId: menuId,
      namaMakanan: namaMakanan,
      hargaBeli: hargaBeli,
      qty: qty,
      discountAmount: discountAmount,
      subtotal: subtotal,
    );
  }

  DetailTransaksiModel copyWith({
    String? id,
    String? transaksiId,
    String? menuId,
    String? namaMakanan,
    double? hargaBeli,
    int? qty,
    double? discountAmount,
    double? subtotal,
  }) {
    return DetailTransaksiModel(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      menuId: menuId ?? this.menuId,
      namaMakanan: namaMakanan ?? this.namaMakanan,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      qty: qty ?? this.qty,
      discountAmount: discountAmount ?? this.discountAmount,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  List<Object?> get props => [
    id,
    transaksiId,
    menuId,
    namaMakanan,
    hargaBeli,
    qty,
    discountAmount,
    subtotal,
  ];
}