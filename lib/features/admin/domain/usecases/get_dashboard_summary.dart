import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/features/admin/domain/entities/dashboard_data.dart';
import 'package:kantin_app/features/admin/domain/repositories/i_dashboard_repository.dart';

class GetDashboardSummary {
  final IDashboardRepository repository;

  GetDashboardSummary(this.repository);

  Future<Either<Failure, DashboardData>> call(String stanId) async {
    return await repository.getDashboardSummary(stanId);
  }
}