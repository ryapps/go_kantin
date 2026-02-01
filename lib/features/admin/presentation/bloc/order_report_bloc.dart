import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_report_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_report_state.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';
import 'package:kantin_app/features/transaksi/domain/repositories/i_transaksi_repository.dart';

class OrderReportBloc extends Bloc<OrderReportEvent, OrderReportState> {
  final ITransaksiRepository transaksiRepository;

  OrderReportBloc({required this.transaksiRepository})
    : super(OrderReportInitial()) {
    on<LoadOrderReport>(_onLoadOrderReport);
    on<ChangeReportPeriod>(_onChangeReportPeriod);
  }

  Future<void> _onLoadOrderReport(
    LoadOrderReport event,
    Emitter<OrderReportState> emit,
  ) async {
    emit(OrderReportLoading());
    try {
      final transactions = await transaksiRepository.getTransaksiByStan(
        event.stanId,
      );
      final List<Transaksi> allTransactions =
          transactions.fold<List<Transaksi>>((_) => <Transaksi>[], (t) => t);

      // Filter by date range
      final filteredTransactions = allTransactions.where((t) {
        return t.createdAt.isAfter(
              event.startDate.subtract(const Duration(days: 1)),
            ) &&
            t.createdAt.isBefore(event.endDate.add(const Duration(days: 1)));
      }).toList();

      // Calculate statistics
      final totalOrders = filteredTransactions.length;
      final completedOrders = filteredTransactions
          .where((t) => t.status == 'sampai')
          .length;
      final cancelledOrders = filteredTransactions
          .where((t) => t.status == 'dibatalkan')
          .length;
      final totalRevenue = filteredTransactions
          .where((t) => t.status == 'sampai')
          .fold(0.0, (sum, t) => sum + t.finalAmount);

      // Daily data
      final dailyMap = <String, DailyOrderData>{};
      for (var transaction in filteredTransactions) {
        final dateKey =
            '${transaction.createdAt.year}-${transaction.createdAt.month}-${transaction.createdAt.day}';
        if (!dailyMap.containsKey(dateKey)) {
          dailyMap[dateKey] = DailyOrderData(
            date: DateTime(
              transaction.createdAt.year,
              transaction.createdAt.month,
              transaction.createdAt.day,
            ),
            orderCount: 0,
            revenue: 0,
          );
        }
        dailyMap[dateKey] = DailyOrderData(
          date: dailyMap[dateKey]!.date,
          orderCount: dailyMap[dateKey]!.orderCount + 1,
          revenue:
              dailyMap[dateKey]!.revenue +
              (transaction.status == 'sampai' ? transaction.finalAmount : 0),
        );
      }
      final dailyData = dailyMap.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      // Top menu items
      final menuSalesMap = <String, MenuItemSales>{};
      for (var transaction in filteredTransactions) {
        if (transaction.status != 'sampai') continue;
        for (var item in transaction.items) {
          if (!menuSalesMap.containsKey(item.menuId)) {
            menuSalesMap[item.menuId] = MenuItemSales(
              menuId: item.menuId,
              menuName: item.namaMakanan,
              quantity: 0,
              revenue: 0,
            );
          }
          menuSalesMap[item.menuId] = MenuItemSales(
            menuId: item.menuId,
            menuName: item.namaMakanan,
            quantity: menuSalesMap[item.menuId]!.quantity + item.qty,
            revenue:
                menuSalesMap[item.menuId]!.revenue + (item.hargaBeli * item.qty),
          );
        }
      }
      final topMenuItems = menuSalesMap.values.toList()
        ..sort((a, b) => b.quantity.compareTo(a.quantity));

      // Hourly data
      final hourlyMap = <int, int>{};
      for (var i = 0; i < 24; i++) {
        hourlyMap[i] = 0;
      }
      for (var transaction in filteredTransactions) {
        final hour = transaction.createdAt.hour;
        hourlyMap[hour] = hourlyMap[hour]! + 1;
      }
      final hourlyData = hourlyMap.entries
          .map((e) => HourlyOrderData(hour: e.key, orderCount: e.value))
          .toList();

      // Status breakdown
      final statusBreakdown = <String, int>{};
      for (var transaction in filteredTransactions) {
        statusBreakdown[transaction.status] =
            (statusBreakdown[transaction.status] ?? 0) + 1;
      }

      emit(
        OrderReportLoaded(
          reportData: OrderReportData(
            totalOrders: totalOrders,
            completedOrders: completedOrders,
            cancelledOrders: cancelledOrders,
            totalRevenue: totalRevenue,
            dailyData: dailyData,
            topMenuItems: topMenuItems,
            hourlyData: hourlyData,
            statusBreakdown: statusBreakdown,
          ),
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      emit(OrderReportError('Gagal memuat laporan: ${e.toString()}'));
    }
  }

  Future<void> _onChangeReportPeriod(
    ChangeReportPeriod event,
    Emitter<OrderReportState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderReportLoaded) {
      // Reload with new date range using the same stanId
      // We need to store stanId in state or emit loading and let UI handle reload
      emit(OrderReportLoading());
    }
  }
}
