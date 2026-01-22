import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaksi.dart';

abstract class TransaksiHistoryEvent extends Equatable {
  const TransaksiHistoryEvent();

  @override
  List<Object?> get props => [];
}

class TransaksiHistoryStarted extends TransaksiHistoryEvent {
  const TransaksiHistoryStarted();
}

class TransaksiHistoryStreamUpdated extends TransaksiHistoryEvent {
  final Either<Failure, List<Transaksi>> result;

  const TransaksiHistoryStreamUpdated(this.result);

  @override
  List<Object?> get props => [result];
}
