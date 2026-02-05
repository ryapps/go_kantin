import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetSiswaProfileRequested extends ProfileEvent {
  final String userId;

  const GetSiswaProfileRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateSiswaProfileRequested extends ProfileEvent {
  final String siswaId;
  final String? namaSiswa;
  final String? alamat;
  final String? telp;
  final String? fotoPath;

  const UpdateSiswaProfileRequested({
    required this.siswaId,
    this.namaSiswa,
    this.alamat,
    this.telp,
    this.fotoPath,
  });

  @override
  List<Object?> get props => [siswaId, namaSiswa, alamat, telp, fotoPath];
}
