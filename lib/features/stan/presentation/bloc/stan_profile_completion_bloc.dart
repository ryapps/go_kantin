import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/services/cloudinary_service.dart';
import 'package:kantin_app/features/stan/domain/repositories/i_stan_repository.dart';
import 'stan_profile_completion_event.dart';
import 'stan_profile_completion_state.dart';

class StanProfileCompletionBloc extends Bloc<StanProfileCompletionEvent, StanProfileCompletionState> {
  final IStanRepository _stanRepository;

  StanProfileCompletionBloc(this._stanRepository) : super(const StanProfileCompletionInitial()) {
    on<SaveStanProfileRequested>(_onSaveStanProfileRequested);
    on<CheckStanProfileRequested>(_onCheckStanProfileRequested);
  }

  Future<void> _onSaveStanProfileRequested(
    SaveStanProfileRequested event,
    Emitter<StanProfileCompletionState> emit,
  ) async {
    emit(const StanProfileCompletionLoading());

    try {
      // Get current user ID from the context or auth state
      // For now, we'll assume the user ID is passed in the event
      final userId = event.profileData['userId'] ?? '';

      // Prepare the stan data
      String imageUrl = '';
      if (event.profileData.containsKey('imagePath') && event.profileData['imagePath'] != null) {
        // Upload image to Cloudinary
        final imagePath = event.profileData['imagePath'];
        if (imagePath.isNotEmpty) {
          imageUrl = await CloudinaryService.uploadImage(File(imagePath));
        }
      }

      final stanData = {
        'userId': userId,
        'namaStan': event.profileData['namaStan'],
        'namaPemilik': event.profileData['namaPemilik'],
        'telp': event.profileData['telp'],
        'description': event.profileData['description'],
        'openTime': event.profileData['openTime'],
        'closeTime': event.profileData['closeTime'],
        'location': event.profileData['location'],
        'categories': event.profileData['categories'],
        'isActive': true,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'rating': 0.0,
        'reviewCount': 0,
        'imageUrl': imageUrl, // Use the uploaded image URL from Cloudinary
      };

      // Save the stan profile to Firebase
      await _stanRepository.createStanWithProfileData(stanData);

      emit(const StanProfileSavedSuccessfully());
    } catch (e) {
      emit(StanProfileCompletionError(e.toString()));
    }
  }

  Future<void> _onCheckStanProfileRequested(
    CheckStanProfileRequested event,
    Emitter<StanProfileCompletionState> emit,
  ) async {
    emit(const StanProfileCompletionLoading());

    try {
      // If userId is not provided in the event, try to get it from somewhere else
      // For now, we'll assume it's passed in the event
      final userId = event.userId;

      if (userId.isEmpty) {
        emit(const StanProfileCompletionError('User ID is required to check stan profile'));
        return;
      }

      // Try to get stan by user ID
      final result = await _stanRepository.getStanByUserId(userId);

      result.fold(
        (failure) {
          // If there's a failure getting the stan, it might mean the profile doesn't exist
          emit(StanProfileCompletionError(failure.message));
        },
        (stan) {
          // If we successfully get the stan, the profile exists
          emit(const StanProfileSavedSuccessfully());
        },
      );
    } catch (e) {
      emit(StanProfileCompletionError(e.toString()));
    }
  }
}