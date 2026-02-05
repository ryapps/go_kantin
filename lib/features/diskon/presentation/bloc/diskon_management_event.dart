import 'package:equatable/equatable.dart';

abstract class DiskonManagementEvent extends Equatable {
  const DiskonManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadDiskons extends DiskonManagementEvent {
  final String stanId;

  const LoadDiskons(this.stanId);

  @override
  List<Object?> get props => [stanId];
}

class CreateDiskonEvent extends DiskonManagementEvent {
  final String stanId;
  final String namaDiskon;
  final double persentaseDiskon;
  final DateTime tanggalAwal;
  final DateTime tanggalAkhir;

  const CreateDiskonEvent({
    required this.stanId,
    required this.namaDiskon,
    required this.persentaseDiskon,
    required this.tanggalAwal,
    required this.tanggalAkhir,
  });

  @override
  List<Object?> get props => [
    stanId,
    namaDiskon,
    persentaseDiskon,
    tanggalAwal,
    tanggalAkhir,
  ];
}

class UpdateDiskonEvent extends DiskonManagementEvent {
  final String diskonId;
  final String? namaDiskon;
  final double? persentaseDiskon;
  final DateTime? tanggalAwal;
  final DateTime? tanggalAkhir;

  const UpdateDiskonEvent({
    required this.diskonId,
    this.namaDiskon,
    this.persentaseDiskon,
    this.tanggalAwal,
    this.tanggalAkhir,
  });

  @override
  List<Object?> get props => [
    diskonId,
    namaDiskon,
    persentaseDiskon,
    tanggalAwal,
    tanggalAkhir,
  ];
}

class DeleteDiskonEvent extends DiskonManagementEvent {
  final String diskonId;
  final String stanId;

  const DeleteDiskonEvent({required this.diskonId, required this.stanId});

  @override
  List<Object?> get props => [diskonId, stanId];
}

class ToggleDiskonStatusEvent extends DiskonManagementEvent {
  final String diskonId;
  final bool isActive;

  const ToggleDiskonStatusEvent({
    required this.diskonId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [diskonId, isActive];
}

class AssignDiskonToMenusEvent extends DiskonManagementEvent {
  final String diskonId;
  final List<String> menuIds;

  const AssignDiskonToMenusEvent({
    required this.diskonId,
    required this.menuIds,
  });

  @override
  List<Object?> get props => [diskonId, menuIds];
}
