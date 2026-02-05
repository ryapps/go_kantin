import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {}

class AddToFavorite extends FavoriteEvent {
  final String id;
  final String namaStan;
  final String namaPemilik;
  final String description;
  final String imageUrl;

  const AddToFavorite({
    required this.id,
    required this.namaStan,
    required this.namaPemilik,
    required this.description,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, namaStan, namaPemilik, description, imageUrl];
}

class RemoveFromFavorite extends FavoriteEvent {
  final String stanId;

  const RemoveFromFavorite(this.stanId);

  @override
  List<Object?> get props => [stanId];
}

class ToggleFavorite extends FavoriteEvent {
  final String id;
  final String namaStan;
  final String namaPemilik;
  final String description;
  final String imageUrl;

  const ToggleFavorite({
    required this.id,
    required this.namaStan,
    required this.namaPemilik,
    required this.description,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, namaStan, namaPemilik, description, imageUrl];
}

class CheckFavoriteStatus extends FavoriteEvent {
  final String stanId;

  const CheckFavoriteStatus(this.stanId);

  @override
  List<Object?> get props => [stanId];
}

class ClearAllFavorites extends FavoriteEvent {}
