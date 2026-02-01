import 'package:equatable/equatable.dart';

abstract class OrderReportState extends Equatable {
  const OrderReportState();

  @override
  List<Object?> get props => [];
}

class OrderReportInitial extends OrderReportState {}

class OrderReportLoading extends OrderReportState {}

class OrderReportLoaded extends OrderReportState {
  final OrderReportData reportData;
  final DateTime startDate;
  final DateTime endDate;

  const OrderReportLoaded({
    required this.reportData,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [reportData, startDate, endDate];
}

class OrderReportError extends OrderReportState {
  final String message;

  const OrderReportError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderReportData {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final List<DailyOrderData> dailyData;
  final List<MenuItemSales> topMenuItems;
  final List<HourlyOrderData> hourlyData;
  final Map<String, int> statusBreakdown;

  OrderReportData({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.dailyData,
    required this.topMenuItems,
    required this.hourlyData,
    required this.statusBreakdown,
  });
}

class DailyOrderData {
  final DateTime date;
  final int orderCount;
  final double revenue;

  DailyOrderData({
    required this.date,
    required this.orderCount,
    required this.revenue,
  });
}

class MenuItemSales {
  final String menuId;
  final String menuName;
  final int quantity;
  final double revenue;

  MenuItemSales({
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.revenue,
  });
}

class HourlyOrderData {
  final int hour;
  final int orderCount;

  HourlyOrderData({
    required this.hour,
    required this.orderCount,
  });
}
