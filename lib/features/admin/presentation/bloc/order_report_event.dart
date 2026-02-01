import 'package:equatable/equatable.dart';

abstract class OrderReportEvent extends Equatable {
  const OrderReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderReport extends OrderReportEvent {
  final String stanId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadOrderReport({
    required this.stanId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [stanId, startDate, endDate];
}

class ChangeReportPeriod extends OrderReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const ChangeReportPeriod({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
