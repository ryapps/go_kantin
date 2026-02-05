import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/siswa/domain/entities/siswa.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Siswa siswa;

  const ProfileLoaded(this.siswa);

  @override
  List<Object?> get props => [siswa];
}

class ProfileUpdateSuccess extends ProfileState {
  final Siswa siswa;

  const ProfileUpdateSuccess(this.siswa);

  @override
  List<Object?> get props => [siswa];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
