import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:kantin_app/features/siswa/domain/usecases/get_siswa_profile_usecase.dart';
import 'package:kantin_app/features/siswa/domain/usecases/update_siswa_profile_usecase.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetSiswaProfileUseCase getSiswaProfileUseCase;
  final UpdateSiswaProfileUseCase updateSiswaProfileUseCase;

  ProfileBloc({
    required this.getSiswaProfileUseCase,
    required this.updateSiswaProfileUseCase,
  }) : super(const ProfileInitial()) {
    on<GetSiswaProfileRequested>(_onGetSiswaProfileRequested);
    on<UpdateSiswaProfileRequested>(_onUpdateSiswaProfileRequested);
  }

  Future<void> _onGetSiswaProfileRequested(
    GetSiswaProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await getSiswaProfileUseCase(
      GetSiswaProfileParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (siswa) => emit(ProfileLoaded(siswa)),
    );
  }

  Future<void> _onUpdateSiswaProfileRequested(
    UpdateSiswaProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await updateSiswaProfileUseCase(
      UpdateSiswaProfileParams(
        siswaId: event.siswaId,
        namaSiswa: event.namaSiswa,
        alamat: event.alamat,
        telp: event.telp,
        fotoPath: event.fotoPath,
      ),
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (siswa) => emit(ProfileUpdateSuccess(siswa)),
    );
  }
}
