import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';
import 'package:kantin_app/features/transaksi/data/models/detail_transaksi_model.dart';

class TransaksiModel extends Equatable {
  final String id;
  final String siswaId; // ref to Siswa
  final String siswaName; // denormalized
  final String stanId; // ref to Stan
  final String stanName; // denormalized
  final List<DetailTransaksiModel> items;
  final double totalAmount;
  final double totalDiscount;
  final double finalAmount;
  final String status; // 'belum_dikonfirm' | 'dimasak' | 'diantar' | 'sampai' | 'dibatalkan'
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const TransaksiModel({
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransaksiModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    List<DetailTransaksiModel> items,
  ) {
    final data = snapshot.data()!;
    return TransaksiModel(
      id: snapshot.id,
      siswaId: data['siswaId'] ?? '',
      siswaName: data['siswaName'] ?? '',
      stanId: data['stanId'] ?? '',
      stanName: data['stanName'] ?? '',
      items: items,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      totalDiscount: (data['totalDiscount'] ?? 0).toDouble(),
      finalAmount: (data['finalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'belum_dikonfirm',
      createdAt: data['createdAt'] ?? FieldValue.serverTimestamp() as Timestamp,
      updatedAt: data['updatedAt'] ?? FieldValue.serverTimestamp() as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'siswaId': siswaId,
      'siswaName': siswaName,
      'stanId': stanId,
      'stanName': stanName,
      'items': items.map((item) => item.toFirestore()).toList(),
      'totalAmount': totalAmount,
      'totalDiscount': totalDiscount,
      'finalAmount': finalAmount,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>?;
    final items = itemsJson?.map((item) => DetailTransaksiModel.fromJson(item)).toList() ?? [];
    
    return TransaksiModel(
      id: json['id'] ?? '',
      siswaId: json['siswaId'] ?? '',
      siswaName: json['siswaName'] ?? '',
      stanId: json['stanId'] ?? '',
      stanName: json['stanName'] ?? '',
      items: items,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      totalDiscount: (json['totalDiscount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'belum_dikonfirm',
      createdAt: json['createdAt'] != null 
          ? Timestamp.fromDate(DateTime.parse(json['createdAt'])) 
          : Timestamp.now(),
      updatedAt: json['updatedAt'] != null 
          ? Timestamp.fromDate(DateTime.parse(json['updatedAt'])) 
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siswaId': siswaId,
      'siswaName': siswaName,
      'stanId': stanId,
      'stanName': stanName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalDiscount': totalDiscount,
      'finalAmount': finalAmount,
      'status': status,
      'createdAt': createdAt.toDate().toIso8601String(),
      'updatedAt': updatedAt.toDate().toIso8601String(),
    };
  }

  factory TransaksiModel.fromEntity(Transaksi entity) {
    return TransaksiModel(
      id: entity.id,
      siswaId: entity.siswaId,
      siswaName: entity.siswaName,
      stanId: entity.stanId,
      stanName: entity.stanName,
      items: entity.items.map((item) => DetailTransaksiModel.fromEntity(item)).toList(),
      totalAmount: entity.totalAmount,
      totalDiscount: entity.totalDiscount,
      finalAmount: entity.finalAmount,
      status: entity.status,
      createdAt: Timestamp.fromDate(entity.createdAt),
      updatedAt: Timestamp.fromDate(entity.updatedAt),
    );
  }

  Transaksi toEntity() {
    return Transaksi(
      id: id,
      siswaId: siswaId,
      siswaName: siswaName,
      stanId: stanId,
      stanName: stanName,
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      totalDiscount: totalDiscount,
      finalAmount: finalAmount,
      status: status,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }

  TransaksiModel copyWith({
    String? id,
    String? siswaId,
    String? siswaName,
    String? stanId,
    String? stanName,
    List<DetailTransaksiModel>? items,
    double? totalAmount,
    double? totalDiscount,
    double? finalAmount,
    String? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return TransaksiModel(
      id: id ?? this.id,
      siswaId: siswaId ?? this.siswaId,
      siswaName: siswaName ?? this.siswaName,
      stanId: stanId ?? this.stanId,
      stanName: stanName ?? this.stanName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get canBeCancelled => status == 'belum_dikonfirm';
  bool get isCompleted => status == 'sampai';
  bool get isCancelled => status == 'dibatalkan';
  bool get isPending => status == 'belum_dikonfirm' || status == 'dimasak' || status == 'diantar';

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
    createdAt,
    updatedAt,
  ];
}