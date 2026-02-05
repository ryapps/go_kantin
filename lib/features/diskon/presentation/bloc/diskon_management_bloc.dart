import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/diskon/domain/usecases/create_diskon_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/delete_diskon_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/get_diskons_by_stan_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/update_diskon_usecase.dart';

import 'diskon_management_event.dart';
import 'diskon_management_state.dart';

class DiskonManagementBloc
    extends Bloc<DiskonManagementEvent, DiskonManagementState> {
  final CreateDiskonUseCase createDiskonUseCase;
  final UpdateDiskonUseCase updateDiskonUseCase;
  final DeleteDiskonUseCase deleteDiskonUseCase;
  final GetDiskonsByStanUseCase getDiskonsByStanUseCase;

  DiskonManagementBloc({
    required this.createDiskonUseCase,
    required this.updateDiskonUseCase,
    required this.deleteDiskonUseCase,
    required this.getDiskonsByStanUseCase,
  }) : super(DiskonManagementInitial()) {
    on<LoadDiskons>(_onLoadDiskons);
    on<CreateDiskonEvent>(_onCreateDiskon);
    on<UpdateDiskonEvent>(_onUpdateDiskon);
    on<DeleteDiskonEvent>(_onDeleteDiskon);
    on<ToggleDiskonStatusEvent>(_onToggleStatus);
  }

  Future<void> _onLoadDiskons(
    LoadDiskons event,
    Emitter<DiskonManagementState> emit,
  ) async {
    emit(DiskonManagementLoading());

    final result = await getDiskonsByStanUseCase(
      GetDiskonsByStanParams(stanId: event.stanId),
    );

    result.fold((failure) => emit(DiskonManagementError(failure.message)), (
      diskons,
    ) {
      final now = DateTime.now();
      final activeDiskons = diskons
          .where(
            (d) =>
                d.isActive &&
                now.isAfter(d.tanggalAwal) &&
                now.isBefore(d.tanggalAkhir),
          )
          .toList();
      final expiredDiskons = diskons
          .where((d) => now.isAfter(d.tanggalAkhir))
          .toList();

      emit(
        DiskonManagementLoaded(
          diskons: diskons,
          activeDiskons: activeDiskons,
          expiredDiskons: expiredDiskons,
        ),
      );
    });
  }

  Future<void> _onCreateDiskon(
    CreateDiskonEvent event,
    Emitter<DiskonManagementState> emit,
  ) async {
    emit(DiskonManagementLoading());

    final result = await createDiskonUseCase(
      CreateDiskonParams(
        stanId: event.stanId,
        namaDiskon: event.namaDiskon,
        persentaseDiskon: event.persentaseDiskon,
        tanggalAwal: event.tanggalAwal,
        tanggalAkhir: event.tanggalAkhir,
      ),
    );

    result.fold((failure) => emit(DiskonManagementError(failure.message)), (
      diskon,
    ) {
      emit(DiskonCreatedSuccess(diskon));
      // Reload diskons
      add(LoadDiskons(event.stanId));
    });
  }

  Future<void> _onUpdateDiskon(
    UpdateDiskonEvent event,
    Emitter<DiskonManagementState> emit,
  ) async {
    emit(DiskonManagementLoading());

    final result = await updateDiskonUseCase(
      UpdateDiskonParams(
        diskonId: event.diskonId,
        namaDiskon: event.namaDiskon,
        persentaseDiskon: event.persentaseDiskon,
        tanggalAwal: event.tanggalAwal,
        tanggalAkhir: event.tanggalAkhir,
      ),
    );

    result.fold((failure) => emit(DiskonManagementError(failure.message)), (
      diskon,
    ) {
      emit(DiskonUpdatedSuccess(diskon));
    });
  }

  Future<void> _onDeleteDiskon(
    DeleteDiskonEvent event,
    Emitter<DiskonManagementState> emit,
  ) async {
    emit(DiskonManagementLoading());

    final result = await deleteDiskonUseCase(
      DeleteDiskonParams(diskonId: event.diskonId),
    );

    result.fold((failure) => emit(DiskonManagementError(failure.message)), (_) {
      emit(DiskonDeletedSuccess(event.diskonId));
      // Reload diskons
      add(LoadDiskons(event.stanId));
    });
  }

  Future<void> _onToggleStatus(
    ToggleDiskonStatusEvent event,
    Emitter<DiskonManagementState> emit,
  ) async {
    emit(DiskonManagementLoading());

    // Update with only isActive status
    // Note: Repository needs to support isActive parameter
    final result = await updateDiskonUseCase(
      UpdateDiskonParams(diskonId: event.diskonId),
    );

    result.fold(
      (failure) => emit(DiskonManagementError(failure.message)),
      (diskon) => emit(DiskonUpdatedSuccess(diskon)),
    );
  }
}
