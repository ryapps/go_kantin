import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stan.dart';
import '../../domain/repositories/i_stan_repository.dart';
import '../datasources/stan_datasource.dart';

class StanRepository implements IStanRepository {
  final StanRemoteDatasource _datasource;
  final FirebaseFirestore _firestore;

  StanRepository({
    required StanRemoteDatasource datasource,
    required FirebaseFirestore firestore,
  })  : _datasource = datasource,
        _firestore = firestore;

  @override
  Future<Either<Failure, Stan>> createStan({
    required String userId,
    required String namaStan,
    required String namaPemilik,
    required String telp,
  }) async {
    try {
      final stanModel = await _datasource.createStan(
        userId: userId,
        namaStan: namaStan,
        namaPemilik: namaPemilik,
        telp: telp,
      );
      return Right(stanModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Stan>>> getAllStans() async {
    try {
      final stanModels = await _datasource.getAllStans();
      return Right(stanModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Stan>> getStanById(String stanId) async {
    try {
      final stanModel = await _datasource.getStanById(stanId);
      return Right(stanModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Stan>> getStanByUserId(String userId) async {
    try {
      final stanModel = await _datasource.getStanByUserId(userId);
      return Right(stanModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Stan>> updateStan({
    required String stanId,
    String? namaStan,
    String? namaPemilik,
    String? telp,
  }) async {
    try {
      final stanModel = await _datasource.updateStan(
        stanId: stanId,
        namaStan: namaStan,
        namaPemilik: namaPemilik,
        telp: telp,
      );
      return Right(stanModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> activateStan(String stanId) async {
    try {
      await _datasource.activateStan(stanId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateStan(String stanId) async {
    try {
      await _datasource.deactivateStan(stanId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStan(String stanId) async {
    try {
      await _datasource.deleteStan(stanId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Stan>>> watchAllStans() {
    return _datasource.watchAllStans().map(
      (stanModels) => Right<Failure, List<Stan>>(
        stanModels.map((model) => model.toEntity()).toList(),
      ),
    ).handleError(
      (e) => Left<Failure, List<Stan>>(ServerFailure(e.toString())),
    );
  }
}