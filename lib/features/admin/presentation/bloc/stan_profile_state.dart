import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';

abstract class StanProfileState extends Equatable {
  const StanProfileState();

  @override
  List<Object?> get props => [];
}

class StanProfileInitial extends StanProfileState {}

class StanProfileLoading extends StanProfileState {}

class StanProfileLoaded extends StanProfileState {
  final Stan stan;
  final String? localImagePath;

  const StanProfileLoaded(this.stan, {this.localImagePath});

  @override
  List<Object?> get props => [stan, localImagePath];
}

class StanProfileImagePicked extends StanProfileState {
  final Stan stan;
  final String imagePath;

  const StanProfileImagePicked(this.stan, this.imagePath);

  @override
  List<Object?> get props => [stan, imagePath];
}

class StanProfileUpdating extends StanProfileState {
  final Stan stan;

  const StanProfileUpdating(this.stan);

  @override
  List<Object?> get props => [stan];
}

class StanProfileUpdateSuccess extends StanProfileState {
  final Stan stan;
  final String message;

  const StanProfileUpdateSuccess(this.stan, this.message);

  @override
  List<Object?> get props => [stan, message];
}

class StanProfileError extends StanProfileState {
  final String message;

  const StanProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
