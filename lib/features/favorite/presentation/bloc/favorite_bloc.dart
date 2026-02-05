import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/favorite/data/models/favorite_stan_model.dart';
import 'package:kantin_app/features/favorite/data/services/favorite_service.dart';
import 'package:kantin_app/features/favorite/presentation/bloc/favorite_event.dart';
import 'package:kantin_app/features/favorite/presentation/bloc/favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteService favoriteService;

  FavoriteBloc({required this.favoriteService}) : super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorite>(_onAddToFavorite);
    on<RemoveFromFavorite>(_onRemoveFromFavorite);
    on<ToggleFavorite>(_onToggleFavorite);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
    on<ClearAllFavorites>(_onClearAllFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      emit(FavoriteLoading());
      final favorites = favoriteService.getAllFavorites();

      // Create favorite status map
      final Map<String, bool> favoriteStatus = {};
      for (var fav in favorites) {
        favoriteStatus[fav.id] = true;
      }

      emit(
        FavoriteLoaded(favorites: favorites, favoriteStatus: favoriteStatus),
      );
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onAddToFavorite(
    AddToFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final favorite = FavoriteStanModel.fromStan(
        id: event.id,
        namaStan: event.namaStan,
        namaPemilik: event.namaPemilik,
        description: event.description,
        imageUrl: event.imageUrl,
      );

      await favoriteService.addFavorite(favorite);

      // Reload favorites
      add(LoadFavorites());
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorite(
    RemoveFromFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await favoriteService.removeFavorite(event.stanId);

      // Reload favorites
      add(LoadFavorites());
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final favorite = FavoriteStanModel.fromStan(
        id: event.id,
        namaStan: event.namaStan,
        namaPemilik: event.namaPemilik,
        description: event.description,
        imageUrl: event.imageUrl,
      );

      final isFavorite = await favoriteService.toggleFavorite(favorite);

      // Emit toggled state
      emit(FavoriteToggled(isFavorite: isFavorite, stanId: event.id));

      // Reload favorites
      add(LoadFavorites());
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatus event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final isFavorite = favoriteService.isFavorite(event.stanId);

      if (state is FavoriteLoaded) {
        final currentState = state as FavoriteLoaded;
        final updatedStatus = Map<String, bool>.from(
          currentState.favoriteStatus,
        );
        updatedStatus[event.stanId] = isFavorite;

        emit(currentState.copyWith(favoriteStatus: updatedStatus));
      }
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onClearAllFavorites(
    ClearAllFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await favoriteService.clearAll();

      // Reload favorites
      add(LoadFavorites());
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  bool isFavorite(String stanId) {
    return favoriteService.isFavorite(stanId);
  }
}
