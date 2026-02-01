import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/features/admin/domain/entities/dashboard_data.dart';

abstract class IDashboardRepository {
  /// Get dashboard summary for a specific stan
  Future<Either<Failure, DashboardData>> getDashboardSummary(String stanId);

  /// Update dashboard data for a specific stan
  Future<Either<Failure, DashboardData>> updateDashboardData(DashboardData dashboardData);

  /// Refresh dashboard data based on latest transactions
  Future<Either<Failure, DashboardData>> refreshDashboardData(String stanId);
}