import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaksi.dart';

abstract class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent();

  @override
  List<Object?> get props => [];
}

class OrderTrackingStarted extends OrderTrackingEvent {
  final String transaksiId;

  const OrderTrackingStarted(this.transaksiId);

  @override
  List<Object?> get props => [transaksiId];
}

class OrderTrackingStreamUpdated extends OrderTrackingEvent {
  final Either<Failure, Transaksi> result;

  const OrderTrackingStreamUpdated(this.result);

  @override
  List<Object?> get props => [result];
}
