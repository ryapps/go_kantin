import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/favorite/data/models/favorite_stan_model.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<FavoriteStanModel> favorites;
  final Map<String, bool> favoriteStatus; // stanId -> isFavorite

  const FavoriteLoaded({
    required this.favorites,
    this.favoriteStatus = const {},
  });

  @override
  List<Object?> get props => [favorites, favoriteStatus];

  FavoriteLoaded copyWith({
    List<FavoriteStanModel>? favorites,
    Map<String, bool>? favoriteStatus,
  }) {
    return FavoriteLoaded(
      favorites: favorites ?? this.favorites,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
    );
  }
}

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoriteToggled extends FavoriteState {
  final bool isFavorite;
  final String stanId;

  const FavoriteToggled({required this.isFavorite, required this.stanId});

  @override
  List<Object?> get props => [isFavorite, stanId];
}
