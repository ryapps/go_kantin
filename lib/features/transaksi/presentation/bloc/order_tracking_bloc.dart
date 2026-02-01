import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/utils/constants.dart';

import '../../domain/repositories/i_transaksi_repository.dart';
import 'order_tracking_event.dart';
import 'order_tracking_state.dart';

class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final ITransaksiRepository transaksiRepository;
  StreamSubscription? _subscription;

  OrderTrackingBloc({required this.transaksiRepository})
    : super(const OrderTrackingLoading()) {
    on<OrderTrackingStarted>(_onStarted);
    on<OrderTrackingStreamUpdated>(_onStreamUpdated);
    on<CancelOrderRequested>(_onCancelOrderRequested);
  }

  Future<void> _onStarted(
    OrderTrackingStarted event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(const OrderTrackingLoading());
    await _subscription?.cancel();

    _subscription = transaksiRepository
        .watchTransaksiById(event.transaksiId)
        .listen((result) {
          add(OrderTrackingStreamUpdated(result));
        });
  }

  Future<void> _onStreamUpdated(
    OrderTrackingStreamUpdated event,
    Emitter<OrderTrackingState> emit,
  ) async {
    event.result.fold(
      (failure) => emit(OrderTrackingError(failure.message)),
      (transaksi) => emit(OrderTrackingLoaded(transaksi)),
    );
  }

  Future<void> _onCancelOrderRequested(
    CancelOrderRequested event,
    Emitter<OrderTrackingState> emit,
  ) async {
    // Update the order status to cancelled
    final result = await transaksiRepository.updateTransaksiStatus(
      transaksiId: event.transaksiId,
      newStatus: AppConstants.statusDibatalkan,
    );

    result.fold(
      (failure) => emit(OrderTrackingError(failure.message)),
      (updatedTransaksi) => emit(OrderTrackingLoaded(updatedTransaksi)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
