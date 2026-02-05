import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';
import 'package:kantin_app/features/stan/domain/usecases/get_all_stans_usecase.dart';
import 'package:kantin_app/features/stan/presentation/bloc/all_canteens_event.dart';
import 'package:kantin_app/features/stan/presentation/bloc/all_canteens_state.dart';

class AllCanteensBloc extends Bloc<AllCanteensEvent, AllCanteensState> {
  final GetAllStansUseCase getAllStansUseCase;

  static const int _pageSize = 10;
  List<Stan> _allCanteens = [];
  int _currentPage = 0;

  AllCanteensBloc({required this.getAllStansUseCase})
    : super(AllCanteensInitial()) {
    on<LoadAllCanteens>(_onLoadAllCanteens);
    on<LoadMoreCanteens>(_onLoadMoreCanteens);
    on<RefreshCanteens>(_onRefreshCanteens);
    on<SearchCanteens>(_onSearchCanteens);
  }

  Future<void> _onLoadAllCanteens(
    LoadAllCanteens event,
    Emitter<AllCanteensState> emit,
  ) async {
    emit(AllCanteensLoading());

    final result = await getAllStansUseCase.call();

    result.fold((failure) => emit(AllCanteensError(failure.toString())), (
      canteens,
    ) {
      _allCanteens = canteens;
      _currentPage = 1;

      final paginatedCanteens = _getPaginatedCanteens();
      final hasReachedMax = paginatedCanteens.length >= _allCanteens.length;

      emit(
        AllCanteensLoaded(
          canteens: paginatedCanteens,
          hasReachedMax: hasReachedMax,
        ),
      );
    });
  }

  Future<void> _onLoadMoreCanteens(
    LoadMoreCanteens event,
    Emitter<AllCanteensState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AllCanteensLoaded) return;
    if (currentState.hasReachedMax) return;
    if (currentState.isLoadingMore) return;

    // Set loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _currentPage++;
    final paginatedCanteens = _getPaginatedCanteens();
    final hasReachedMax = paginatedCanteens.length >= _allCanteens.length;

    emit(
      AllCanteensLoaded(
        canteens: paginatedCanteens,
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
        searchQuery: currentState.searchQuery,
      ),
    );
  }

  Future<void> _onRefreshCanteens(
    RefreshCanteens event,
    Emitter<AllCanteensState> emit,
  ) async {
    final result = await getAllStansUseCase.call();

    result.fold((failure) => emit(AllCanteensError(failure.toString())), (
      canteens,
    ) {
      _allCanteens = canteens;
      _currentPage = 1;

      final paginatedCanteens = _getPaginatedCanteens();
      final hasReachedMax = paginatedCanteens.length >= _allCanteens.length;

      emit(
        AllCanteensLoaded(
          canteens: paginatedCanteens,
          hasReachedMax: hasReachedMax,
        ),
      );
    });
  }

  Future<void> _onSearchCanteens(
    SearchCanteens event,
    Emitter<AllCanteensState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AllCanteensLoaded) return;

    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      // Reset to original list
      _currentPage = 1;
      final paginatedCanteens = _getPaginatedCanteens();
      final hasReachedMax = paginatedCanteens.length >= _allCanteens.length;

      emit(
        AllCanteensLoaded(
          canteens: paginatedCanteens,
          hasReachedMax: hasReachedMax,
          searchQuery: null,
        ),
      );
      return;
    }

    // Filter canteens based on search query
    final filteredCanteens = _allCanteens.where((canteen) {
      final namaStan = canteen.namaStan.toLowerCase();
      final namaPemilik = canteen.namaPemilik.toLowerCase();
      final description = canteen.description.toLowerCase();

      return namaStan.contains(query) ||
          namaPemilik.contains(query) ||
          description.contains(query);
    }).toList();

    emit(
      AllCanteensLoaded(
        canteens: filteredCanteens,
        hasReachedMax: true, // Search results are not paginated
        searchQuery: query,
      ),
    );
  }

  List<Stan> _getPaginatedCanteens() {
    final endIndex = _currentPage * _pageSize;
    if (endIndex >= _allCanteens.length) {
      return _allCanteens;
    }
    return _allCanteens.sublist(0, endIndex);
  }
}
