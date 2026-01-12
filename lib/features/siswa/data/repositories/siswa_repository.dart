import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/siswa.dart';
import '../../domain/repositories/i_student_repository.dart';
import '../datasources/siswa_datasource.dart';

class SiswaRepository implements ISiswaRepository {
  final SiswaRemoteDatasource _datasource;
  final FirebaseFirestore _firestore;

  SiswaRepository({
    required SiswaRemoteDatasource datasource,
    required FirebaseFirestore firestore,
  })  : _datasource = datasource,
        _firestore = firestore;

  @override
  Future<Either<Failure, Siswa>> createSiswa({
    required String userId,
    required String namaSiswa,
    required String alamat,
    required String telp,
    required String fotoPath,
  }) async {
    try {
      final siswaModel = await _datasource.createSiswa(
        userId: userId,
        namaSiswa: namaSiswa,
        alamat: alamat,
        telp: telp,
        fotoPath: fotoPath,
      );
      return Right(siswaModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Siswa>> getSiswaByUserId(String userId) async {
    try {
      final siswaModel = await _datasource.getSiswaByUserId(userId);
      return Right(siswaModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Siswa>> getSiswaById(String siswaId) async {
    try {
      final siswaModel = await _datasource.getSiswaById(siswaId);
      return Right(siswaModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Siswa>> updateSiswa({
    required String siswaId,
    String? namaSiswa,
    String? alamat,
    String? telp,
    String? fotoPath,
  }) async {
    try {
      final siswaModel = await _datasource.updateSiswa(
        siswaId: siswaId,
        namaSiswa: namaSiswa,
        alamat: alamat,
        telp: telp,
        fotoPath: fotoPath,
      );
      return Right(siswaModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementDailyOrderCount(String siswaId) async {
    try {
      await _datasource.incrementDailyOrderCount(siswaId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetDailyOrderCount(String siswaId) async {
    try {
      await _datasource.resetDailyOrderCount(siswaId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canPlaceOrder(String siswaId) async {
    try {
      final canOrder = await _datasource.canPlaceOrder(siswaId);
      return Right(canOrder);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}