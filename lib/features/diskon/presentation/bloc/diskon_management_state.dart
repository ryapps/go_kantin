import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';

abstract class DiskonManagementState extends Equatable {
  const DiskonManagementState();

  @override
  List<Object?> get props => [];
}

class DiskonManagementInitial extends DiskonManagementState {}

class DiskonManagementLoading extends DiskonManagementState {}

class DiskonManagementLoaded extends DiskonManagementState {
  final List<Diskon> diskons;
  final List<Diskon> activeDiskons;
  final List<Diskon> expiredDiskons;

  const DiskonManagementLoaded({
    required this.diskons,
    required this.activeDiskons,
    required this.expiredDiskons,
  });

  @override
  List<Object?> get props => [diskons, activeDiskons, expiredDiskons];
}

class DiskonManagementError extends DiskonManagementState {
  final String message;

  const DiskonManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

class DiskonCreatedSuccess extends DiskonManagementState {
  final Diskon diskon;

  const DiskonCreatedSuccess(this.diskon);

  @override
  List<Object?> get props => [diskon];
}

class DiskonUpdatedSuccess extends DiskonManagementState {
  final Diskon diskon;

  const DiskonUpdatedSuccess(this.diskon);

  @override
  List<Object?> get props => [diskon];
}

class DiskonDeletedSuccess extends DiskonManagementState {
  final String diskonId;

  const DiskonDeletedSuccess(this.diskonId);

  @override
  List<Object?> get props => [diskonId];
}
