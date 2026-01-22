import 'package:equatable/equatable.dart';

import '../../domain/entities/transaksi.dart';

abstract class TransaksiHistoryState extends Equatable {
  const TransaksiHistoryState();

  @override
  List<Object?> get props => [];
}

class TransaksiHistoryLoading extends TransaksiHistoryState {
  const TransaksiHistoryLoading();
}

class TransaksiHistoryLoaded extends TransaksiHistoryState {
  final List<Transaksi> transaksi;

  const TransaksiHistoryLoaded(this.transaksi);

  @override
  List<Object?> get props => [transaksi];
}

class TransaksiHistoryEmpty extends TransaksiHistoryState {
  const TransaksiHistoryEmpty();
}

class TransaksiHistoryError extends TransaksiHistoryState {
  final String message;

  const TransaksiHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
