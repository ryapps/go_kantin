import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/i_transaksi_repository.dart';
import 'transaksi_history_event.dart';
import 'transaksi_history_state.dart';

class TransaksiHistoryBloc
    extends Bloc<TransaksiHistoryEvent, TransaksiHistoryState> {
  final ITransaksiRepository transaksiRepository;
  final firebase_auth.FirebaseAuth firebaseAuth;
  StreamSubscription? _subscription;

  TransaksiHistoryBloc({
    required this.transaksiRepository,
    required this.firebaseAuth,
  }) : super(const TransaksiHistoryLoading()) {
    on<TransaksiHistoryStarted>(_onStarted);
    on<TransaksiHistoryStreamUpdated>(_onStreamUpdated);
  }

  Future<void> _onStarted(
    TransaksiHistoryStarted event,
    Emitter<TransaksiHistoryState> emit,
  ) async {
    emit(const TransaksiHistoryLoading());
    await _subscription?.cancel();

    final user = firebaseAuth.currentUser;
    if (user == null) {
      emit(const TransaksiHistoryError('Silakan login terlebih dahulu'));
      return;
    }

    _subscription = transaksiRepository
        .watchTransaksiByStudent(user.uid)
        .listen((result) {
          add(TransaksiHistoryStreamUpdated(result));
        });
  }

  Future<void> _onStreamUpdated(
    TransaksiHistoryStreamUpdated event,
    Emitter<TransaksiHistoryState> emit,
  ) async {
    event.result.fold(
      (failure) => emit(TransaksiHistoryError(failure.message)),
      (transaksi) => transaksi.isEmpty
          ? emit(const TransaksiHistoryEmpty())
          : emit(TransaksiHistoryLoaded(transaksi)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
