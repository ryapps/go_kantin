import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/dashboard_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/dashboard_state.dart';

import '../../domain/usecases/get_dashboard_summary.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummary getDashboardSummary;
  DashboardBloc({required this.getDashboardSummary})
    : super(DashboardInitial()) {
    on<LoadDashboardSummary>(_onLoadDashboardSummary);
  }

  Future<void> _onLoadDashboardSummary(
    LoadDashboardSummary event,
    Emitter<DashboardState> emit,
  ) async {
    // Check if stanId is empty
    if (event.stanId.isEmpty) {
      return emit(DashboardError('Stan ID tidak valid'));
    }

    emit(DashboardLoading());
    final result = await getDashboardSummary(event.stanId);
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (summary) => emit(
        DashboardLoaded(
          newOrders: summary.newOrders,
          inProcess: summary.inProcess,
          completed: summary.completed,
          revenue: summary.revenue,
          totalCustomers: summary.totalCustomers,
          totalMenuItems: summary.totalMenuItems,
          topSellingItems: summary.topSellingItems,
          monthlyStats: summary.monthlyStats,
        ),
      ),
    );
  }
}
