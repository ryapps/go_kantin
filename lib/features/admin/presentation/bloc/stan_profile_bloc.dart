import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kantin_app/core/services/cloudinary_service.dart';
import 'package:kantin_app/features/admin/domain/repositories/i_admin_repository.dart';
import 'stan_profile_event.dart';
import 'stan_profile_state.dart';

class StanProfileBloc extends Bloc<StanProfileEvent, StanProfileState> {
  final IAdminRepository adminRepository;
  final ImagePicker _picker = ImagePicker();

  StanProfileBloc({required this.adminRepository})
      : super(StanProfileInitial()) {
    on<LoadStanProfile>(_onLoad);
    on<PickStanImage>(_onPickImage);
    on<UpdateStanProfile>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadStanProfile event,
    Emitter<StanProfileState> emit,
  ) async {
    emit(StanProfileLoading());

    final result = await adminRepository.getStanByUserId(event.userId);
    result.fold(
      (f) => emit(StanProfileError(f.message)),
      (stan) => emit(StanProfileLoaded(stan)),
    );
  }

  Future<void> _onPickImage(
    PickStanImage event,
    Emitter<StanProfileState> emit,
  ) async {
    if (state is! StanProfileLoaded) return;
    final current = state as StanProfileLoaded;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    emit(StanProfileImagePicked(current.stan, image.path));
  }

  Future<void> _onUpdate(
    UpdateStanProfile event,
    Emitter<StanProfileState> emit,
  ) async {
    if (state is! StanProfileLoaded &&
        state is! StanProfileImagePicked) return;

    final stan = state is StanProfileLoaded
        ? (state as StanProfileLoaded).stan
        : (state as StanProfileImagePicked).stan;

    final localPath = state is StanProfileImagePicked
        ? (state as StanProfileImagePicked).imagePath
        : null;

    emit(StanProfileUpdating(stan));

    String imageUrl = stan.imageUrl;

    if (localPath != null) {
      imageUrl = await CloudinaryService.uploadImage(File(localPath));
    }

    final result = await adminRepository.updateStan(
      stanId: event.stanId,
      namaStan: event.namaStan,
      namaPemilik: event.namaPemilik,
      telp: event.telp,
      deskripsi: event.description,
      lokasi: event.location,
      jamBuka: event.openTime,
      jamTutup: event.closeTime,
      imageUrl: imageUrl,
    );

    result.fold(
      (f) => emit(StanProfileError(f.message)),
      (_) => emit(
        StanProfileUpdateSuccess(
          stan.copyWith(imageUrl: imageUrl),
          'Profil stan berhasil diperbarui',
        ),
      ),
    );
  }
}
