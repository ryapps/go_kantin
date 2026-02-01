import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/bloc/get_user_stan_event.dart';
import 'package:kantin_app/core/bloc/get_user_stan_state.dart';
import '../../../core/services/stan_service.dart';

// BLoC
class GetUserStanBloc extends Bloc<GetUserStanEvent, GetUserStanState> {
  final StanService stanService;

  GetUserStanBloc({required this.stanService}) : super(GetUserStanInitial()) {
    on<LoadUserStanId>(_onLoadUserStanId);
  }

  Future<void> _onLoadUserStanId(
    LoadUserStanId event,
    Emitter<GetUserStanState> emit,
  ) async {
    emit(GetUserStanLoading());

    try {
      final result = await stanService.getStanIdByUserId(event.userId);
      
      result.fold(
        (failure) => emit(GetUserStanError(failure.message)),
        (stanId) => emit(GetUserStanSuccess(stanId)),
      );
    } catch (e) {
      emit(GetUserStanError('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}