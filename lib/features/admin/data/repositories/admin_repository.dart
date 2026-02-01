import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/exceptions.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kantin_app/features/stan/domain/repositories/i_stan_repository.dart';

import '../../domain/repositories/i_admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepository implements IAdminRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary(
    String stanId,
  ) async {
    try {
      final summary = await remoteDatasource.getDashboardSummary(stanId);
      return Right(summary);
    } catch (e) {
      return Left(
        ServerFailure(
          'Gagal mengambil data ringkasan dashboard: ${e.toString()}',
        ),
      );
    }
  }

  final IAuthRepository authRepository;
  final IStanRepository stanRepository;
  final AdminRemoteDatasource remoteDatasource;

  AdminRepository({
    required this.authRepository,
    required this.stanRepository,
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, void>> registerAdminStan({
    required String username,
    required String email,
    required String password,
    required String namaStan,
    required String namaPemilik,
    required String telp,
    required String deskripsi,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    required String imageUrl,
  }) async {
    try {
      // Step 1: Register user with role admin_stan
      final userResult = await authRepository.register(
        email: email,
        password: password,
        username: username,
        role: 'admin_stan',
      );

      return userResult.fold((failure) => Left(failure), (user) async {
        // Step 2: Create stan profile linked to user
        final stanResult = await stanRepository.createStan(
          userId: user.id,
          namaStan: namaStan,
          namaPemilik: namaPemilik,
          telp: telp,
          description: deskripsi,
          location: lokasi,
          openTime: jamBuka,
          closeTime: jamTutup,
          imageUrl: imageUrl,
        );

        return stanResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      });
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAllCustomers() async {
    try {
      final customers = await remoteDatasource.getAllCustomers();
      return Right(customers);
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengambil data customer: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, dynamic>> getStanByUserId(String userId) async {
    try {
      return await stanRepository.getStanByUserId(userId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStan({
    required String stanId,
    required String namaStan,
    required String namaPemilik,
    required String telp,
    required String deskripsi,
    required String lokasi,
    required String jamBuka,
    required String jamTutup,
    required String imageUrl,
  }) async {
    try {
      final result = await stanRepository.updateStan(
        stanId: stanId,
        namaStan: namaStan,
        namaPemilik: namaPemilik,
        telp: telp,
        description: deskripsi,
        location: lokasi,
        openTime: jamBuka,
        closeTime: jamTutup,
        imageUrl: imageUrl,
      );

      return result.fold((failure) => Left(failure), (_) => const Right(null));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
