import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboardSummary extends DashboardEvent {
  final String stanId;
  const LoadDashboardSummary(this.stanId);
  @override
  List<Object?> get props => [stanId];
}
