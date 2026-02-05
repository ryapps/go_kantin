import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';
import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository_new.dart';

class UpdateDiskonUseCase implements UseCase<Diskon, UpdateDiskonParams> {
  final IDiskonRepository repository;

  UpdateDiskonUseCase(this.repository);

  @override
  Future<Either<Failure, Diskon>> call(UpdateDiskonParams params) async {
    return await repository.updateDiskon(
      diskonId: params.diskonId,
      namaDiskon: params.namaDiskon,
      persentaseDiskon: params.persentaseDiskon,
      tanggalAwal: params.tanggalAwal,
      tanggalAkhir: params.tanggalAkhir,
    );
  }
}

class UpdateDiskonParams extends Equatable {
  final String diskonId;
  final String? namaDiskon;
  final double? persentaseDiskon;
  final DateTime? tanggalAwal;
  final DateTime? tanggalAkhir;

  const UpdateDiskonParams({
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
