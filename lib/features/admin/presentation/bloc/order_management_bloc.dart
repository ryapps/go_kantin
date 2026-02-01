import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_management_state.dart';
import 'package:kantin_app/features/transaksi/domain/entities/transaksi.dart';
import 'package:kantin_app/features/transaksi/domain/repositories/i_transaksi_repository.dart';

class OrderManagementBloc
    extends Bloc<OrderManagementEvent, OrderManagementState> {
  final ITransaksiRepository transaksiRepository;

  OrderManagementBloc({required this.transaksiRepository})
    : super(OrderManagementInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<FilterOrdersByStatus>(_onFilterOrdersByStatus);
    on<FilterOrdersByDate>(_onFilterOrdersByDate);
    on<FilterOrdersByMonth>(_onFilterOrdersByMonth);
    on<SearchOrders>(_onSearchOrders);
    on<RefreshOrders>(_onRefreshOrders);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(OrderManagementLoading());

    final result = await transaksiRepository.getTransaksiByStan(event.stanId);

    result.fold((failure) => emit(OrderManagementError(failure.message)), (
      orders,
    ) {
      // Sort by created date, newest first
      final sortedOrders = List<Transaksi>.from(orders)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(
        OrderManagementLoaded(
          orders: sortedOrders,
          filteredOrders: sortedOrders,
        ),
      );
    });
  }

  Future<void> _onUpdateOrderStatus(
  UpdateOrderStatus event,
  Emitter<OrderManagementState> emit,
) async {
  final currentState = state;

  // If the current state is not OrderManagementLoaded, we need to load the orders first
  if (currentState is! OrderManagementLoaded) {
    // If we don't have the loaded state, we can't update properly
    // Try to load orders first by calling the repository directly
    final result = await transaksiRepository.getTransaksiByStan('');

    List<Transaksi> orders = [];
    String? errorMessage;

    result.fold((failure) {
      errorMessage = failure.message;
    }, (loadedOrders) {
      orders = List<Transaksi>.from(loadedOrders)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

    if (errorMessage != null) {
      emit(OrderManagementError(errorMessage!));
      return;
    }

    // Create a temporary loaded state to work with
    final tempState = OrderManagementLoaded(
      orders: orders,
      filteredOrders: orders,
    );

    emit(tempState.copyWith(isUpdating: true));

    // Now proceed with the update
    final updateResult = await transaksiRepository.updateTransaksiStatus(
      transaksiId: event.transaksiId,
      newStatus: event.newStatus,
    );

    updateResult.fold(
      (failure) {
        emit(tempState.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        ));
      },
      (updatedTransaksi) {
        final updatedOrders = tempState.orders
            .map((o) => o.id == updatedTransaksi.id ? updatedTransaksi : o)
            .toList();

        emit(
          tempState.copyWith(
            orders: updatedOrders,
            filteredOrders: _applyFilters(
              updatedOrders,
              tempState.statusFilter,
              tempState.startDate,
              tempState.endDate,
              tempState.monthFilter,
              tempState.yearFilter,
              tempState.searchQuery,
            ),
            isUpdating: false,
            successMessage: 'Status pesanan berhasil diperbarui',
          ),
        );
      },
    );
  } else {
    // Original logic when state is OrderManagementLoaded
    emit(currentState.copyWith(isUpdating: true));

    final result = await transaksiRepository.updateTransaksiStatus(
      transaksiId: event.transaksiId,
      newStatus: event.newStatus,
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        ));
      },
      (updatedTransaksi) {
        final updatedOrders = currentState.orders
            .map((o) => o.id == updatedTransaksi.id ? updatedTransaksi : o)
            .toList();

        emit(
          currentState.copyWith(
            orders: updatedOrders,
            filteredOrders: _applyFilters(
              updatedOrders,
              currentState.statusFilter,
              currentState.startDate,
              currentState.endDate,
              currentState.monthFilter,
              currentState.yearFilter,
              currentState.searchQuery,
            ),
            isUpdating: false,
            successMessage: 'Status pesanan berhasil diperbarui',
          ),
        );
      },
    );
  }
}


  void _onFilterOrdersByStatus(
    FilterOrdersByStatus event,
    Emitter<OrderManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! OrderManagementLoaded) return;

    final filteredOrders = _applyFilters(
      currentState.orders,
      event.status,
      currentState.startDate,
      currentState.endDate,
      currentState.monthFilter,
      currentState.yearFilter,
      currentState.searchQuery,
    );

    emit(
      OrderManagementLoaded(
        orders: currentState.orders,
        filteredOrders: filteredOrders,
        statusFilter: event.status,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        monthFilter: currentState.monthFilter,
        yearFilter: currentState.yearFilter,
        searchQuery: currentState.searchQuery,
      ),
    );
  }

  void _onFilterOrdersByDate(
    FilterOrdersByDate event,
    Emitter<OrderManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! OrderManagementLoaded) return;

    final filteredOrders = _applyFilters(
      currentState.orders,
      currentState.statusFilter,
      event.startDate,
      event.endDate,
      currentState.monthFilter,
      currentState.yearFilter,
      currentState.searchQuery,
    );

    emit(
      OrderManagementLoaded(
        orders: currentState.orders,
        filteredOrders: filteredOrders,
        statusFilter: currentState.statusFilter,
        startDate: event.startDate,
        endDate: event.endDate,
        monthFilter: currentState.monthFilter,
        yearFilter: currentState.yearFilter,
        searchQuery: currentState.searchQuery,
      ),
    );
  }

  void _onFilterOrdersByMonth(
    FilterOrdersByMonth event,
    Emitter<OrderManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! OrderManagementLoaded) return;

    final filteredOrders = _applyFilters(
      currentState.orders,
      currentState.statusFilter,
      currentState.startDate,
      currentState.endDate,
      event.month,
      event.year,
      currentState.searchQuery,
    );

    emit(
      OrderManagementLoaded(
        orders: currentState.orders,
        filteredOrders: filteredOrders,
        statusFilter: currentState.statusFilter,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        monthFilter: event.month,
        yearFilter: event.year,
        searchQuery: currentState.searchQuery,
      ),
    );
  }

  void _onSearchOrders(SearchOrders event, Emitter<OrderManagementState> emit) {
    final currentState = state;
    if (currentState is! OrderManagementLoaded) return;

    final filteredOrders = _applyFilters(
      currentState.orders,
      currentState.statusFilter,
      currentState.startDate,
      currentState.endDate,
      currentState.monthFilter,
      currentState.yearFilter,
      event.query,
    );

    emit(
      OrderManagementLoaded(
        orders: currentState.orders,
        filteredOrders: filteredOrders,
        statusFilter: currentState.statusFilter,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        monthFilter: currentState.monthFilter,
        yearFilter: currentState.yearFilter,
        searchQuery: event.query,
      ),
    );
  }

  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrderManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrderManagementLoaded) return;

    final result = await transaksiRepository.getTransaksiByStan(event.stanId);

    result.fold((failure) => emit(OrderManagementError(failure.message)), (
      orders,
    ) {
      final sortedOrders = List<Transaksi>.from(orders)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(
        OrderManagementLoaded(
          orders: sortedOrders,
          filteredOrders: _applyFilters(
            sortedOrders,
            currentState.statusFilter,
            currentState.startDate,
            currentState.endDate,
            currentState.monthFilter,
            currentState.yearFilter,
            currentState.searchQuery,
          ),
          statusFilter: currentState.statusFilter,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          monthFilter: currentState.monthFilter,
          yearFilter: currentState.yearFilter,
          searchQuery: currentState.searchQuery,
        ),
      );
    });
  }

  List<Transaksi> _applyFilters(
    List<Transaksi> orders,
    String? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
    int? monthFilter,
    int? yearFilter,
    String? searchQuery,
  ) {
    var filtered = orders;

    // Filter by status
    if (statusFilter != null) {
      filtered = filtered.where((o) => o.status == statusFilter).toList();
    }

    // Filter by date range
    if (startDate != null) {
      filtered = filtered.where((o) {
        return o.createdAt.isAfter(startDate.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((o) {
        return o.createdAt.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by month and year
    if (monthFilter != null && yearFilter != null) {
      filtered = filtered.where((o) {
        return o.createdAt.month == monthFilter && o.createdAt.year == yearFilter;
      }).toList();
    }

    // Filter by search query (siswa name or order ID)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((o) {
        return o.siswaName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            o.id.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }
}
