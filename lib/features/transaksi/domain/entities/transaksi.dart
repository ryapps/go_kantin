import 'package:equatable/equatable.dart';

class DetailTransaksi extends Equatable {
  final String id;
  final String transaksiId; // ref to Transaksi
  final String menuId; // ref to Menu
  final String namaMakanan; // denormalized
  final double hargaBeli; // price at time of purchase
  final int qty;
  final double discountAmount;
  final double subtotal; // (hargaBeli × qty) - discountAmount

  const DetailTransaksi({
    required this.id,
    required this.transaksiId,
    required this.menuId,
    required this.namaMakanan,
    required this.hargaBeli,
    required this.qty,
    this.discountAmount = 0,
    required this.subtotal,
  });

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

class Transaksi extends Equatable {
  final String id;
  final String siswaId; // ref to Siswa
  final String siswaName; // denormalized
  final String stanId; // ref to Stan
  final String stanName; // denormalized
  final List<DetailTransaksi> items;
  final double totalAmount;
  final double totalDiscount;
  final double finalAmount;
  final String
  status; // 'belum_dikonfirm' | 'dimasak' | 'diantar' | 'sampai' | 'dibatalkan'
  final String? paymentMethod; // payment method used for the transaction
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaksi({
    required this.id,
    required this.siswaId,
    required this.siswaName,
    required this.stanId,
    required this.stanName,
    required this.items,
    required this.totalAmount,
    required this.totalDiscount,
    required this.finalAmount,
    required this.status,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get canBeCancelled => status == 'belum_dikonfirm';
  bool get isCompleted => status == 'sampai';
  bool get isCancelled => status == 'dibatalkan';
  bool get isPending =>
      status == 'belum_dikonfirm' || status == 'dimasak' || status == 'diantar';

  @override
  List<Object?> get props => [
    id,
    siswaId,
    siswaName,
    stanId,
    stanName,
    items,
    totalAmount,
    totalDiscount,
    finalAmount,
    status,
    paymentMethod,
    createdAt,
    updatedAt,
  ];
}
