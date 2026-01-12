import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/diskon.dart';
import '../../domain/repositories/i_diskon_repository.dart';
import '../datasources/diskon_datasource.dart';

class DiskonRepository implements IDiskonRepository {
  final DiskonRemoteDatasource _datasource;
  final FirebaseFirestore _firestore;

  DiskonRepository({
    required DiskonRemoteDatasource datasource,
    required FirebaseFirestore firestore,
  })  : _datasource = datasource,
        _firestore = firestore;

  @override
  Future<Either<Failure, Diskon>> createDiskon({
    required String namaDiskon,
    required double persentaseDiskon,
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
  }) async {
    try {
      final diskonModel = await _datasource.createDiskon(
        namaDiskon: namaDiskon,
        persentaseDiskon: persentaseDiskon,
        tanggalAwal: tanggalAwal,
        tanggalAkhir: tanggalAkhir,
      );
      return Right(diskonModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Diskon>>> getAllDiskon() async {
    try {
      final diskonModels = await _datasource.getAllDiskon();
      return Right(diskonModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Diskon>>> getActiveDiskon() async {
    try {
      final diskonModels = await _datasource.getActiveDiskon();
      return Right(diskonModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Diskon>> getDiskonById(String diskonId) async {
    try {
      final diskonModel = await _datasource.getDiskonById(diskonId);
      return Right(diskonModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Diskon>> updateDiskon({
    required String diskonId,
    String? namaDiskon,
    double? persentaseDiskon,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) async {
    try {
      final diskonModel = await _datasource.updateDiskon(
        diskonId: diskonId,
        namaDiskon: namaDiskon,
        persentaseDiskon: persentaseDiskon,
        tanggalAwal: tanggalAwal,
        tanggalAkhir: tanggalAkhir,
      );
      return Right(diskonModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> activateDiskon(String diskonId) async {
    try {
      await _datasource.activateDiskon(diskonId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateDiskon(String diskonId) async {
    try {
      await _datasource.deactivateDiskon(diskonId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDiskon(String diskonId) async {
    try {
      await _datasource.deleteDiskon(diskonId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> linkDiskonToMenu({
    required String diskonId,
    required List<String> menuIds,
  }) async {
    try {
      await _datasource.linkDiskonToMenu(
        diskonId: diskonId,
        menuIds: menuIds,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlinkDiskonFromMenu({
    required String diskonId,
    required List<String> menuIds,
  }) async {
    try {
      await _datasource.unlinkDiskonFromMenu(
        diskonId: diskonId,
        menuIds: menuIds,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getMenuIdsWithDiskon(String diskonId) async {
    try {
      final menuIds = await _datasource.getMenuIdsWithDiskon(diskonId);
      return Right(menuIds);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Diskon?>> getDiskonForMenu(String menuId) async {
    try {
      final diskonModel = await _datasource.getDiskonForMenu(menuId);
      return Right(diskonModel?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Diskon>>> getActiveDiscountsForMenu(String menuId) async {
    try {
      final diskonModels = await _datasource.getActiveDiscountsForMenu(menuId);
      return Right(diskonModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}