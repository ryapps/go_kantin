import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/features/admin/domain/entities/dashboard_data.dart';
import 'package:kantin_app/features/admin/domain/repositories/i_dashboard_repository.dart';
import 'package:kantin_app/features/admin/data/models/dashboard_data_model.dart';
import 'package:kantin_app/features/admin/data/datasources/dashboard_remote_datasource.dart';

class DashboardRepository implements IDashboardRepository {
  final IDashboardRemoteDataSource _remoteDataSource;

  DashboardRepository({
    required IDashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, DashboardData>> getDashboardSummary(String stanId) async {
    try {
      final result = await _remoteDataSource.getDashboardSummary(stanId);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Gagal mengambil data dashboard: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DashboardData>> updateDashboardData(
    DashboardData dashboardData,
  ) async {
    try {
      final result = await _remoteDataSource.updateDashboardData(
        DashboardDataModel.fromEntity(dashboardData),
      );
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Gagal memperbarui data dashboard: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DashboardData>> refreshDashboardData(String stanId) async {
    try {
      final result = await _remoteDataSource.refreshDashboardData(stanId);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Gagal menyegarkan data dashboard: ${e.toString()}'));
    }
  }
}