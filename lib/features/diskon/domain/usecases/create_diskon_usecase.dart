import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';
import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository_new.dart';

class CreateDiskonUseCase implements UseCase<Diskon, CreateDiskonParams> {
  final IDiskonRepository repository;

  CreateDiskonUseCase(this.repository);

  @override
  Future<Either<Failure, Diskon>> call(CreateDiskonParams params) async {
    return await repository.createDiskon(
      stanId: params.stanId,
      namaDiskon: params.namaDiskon,
      persentaseDiskon: params.persentaseDiskon,
      tanggalAwal: params.tanggalAwal,
      tanggalAkhir: params.tanggalAkhir,
    );
  }
}

class CreateDiskonParams extends Equatable {
  final String stanId;
  final String namaDiskon;
  final double persentaseDiskon;
  final DateTime tanggalAwal;
  final DateTime tanggalAkhir;

  const CreateDiskonParams({
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
