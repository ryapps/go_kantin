import 'package:equatable/equatable.dart';

import '../../domain/entities/transaksi.dart';

abstract class OrderTrackingState extends Equatable {
  const OrderTrackingState();

  @override
  List<Object?> get props => [];
}

class OrderTrackingLoading extends OrderTrackingState {
  const OrderTrackingLoading();
}

class OrderTrackingLoaded extends OrderTrackingState {
  final Transaksi transaksi;

  const OrderTrackingLoaded(this.transaksi);

  @override
  List<Object?> get props => [transaksi];
}

class OrderTrackingError extends OrderTrackingState {
  final String message;

  const OrderTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
