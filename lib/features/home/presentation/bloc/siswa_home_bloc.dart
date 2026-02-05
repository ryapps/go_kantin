import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/services/location_service.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_event.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_state.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';
import 'package:kantin_app/features/stan/domain/usecases/get_all_stans_usecase.dart';

class SiswaHomeBloc extends Bloc<SiswaHomeEvent, SiswaHomeState> {
  final GetAllStansUseCase getAllStansUseCase;
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final LocationService locationService;

  SiswaHomeBloc({
    required this.getAllStansUseCase,
    required this.getAllCategoriesUseCase,
    required this.locationService,
  }) : super(const SiswaHomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
    on<RefreshStallsEvent>(_onRefreshStalls);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<ChangeBottomNavEvent>(_onChangeBottomNav);
    on<LoadLocationEvent>(_onLoadLocation);
  }

  Future<void> _onLoadHome(
    LoadHomeEvent event,
    Emitter<SiswaHomeState> emit,
  ) async {
    emit(const SiswaHomeLoading());

    try {
      // Load categories from database
      final categoriesResult = await getAllCategoriesUseCase();
      final categories = categoriesResult.fold(
        (failure) => <Category>[],
        (cats) => cats,
      );

      // Load stalls
      final stallsResult = await getAllStansUseCase();
      final allStalls = stallsResult.fold(
        (failure) => throw Exception(failure.message),
        (stalls) => stalls,
      );

      if (allStalls.isEmpty) {
        emit(const SiswaHomeEmpty());
        return;
      }

      // Tidak ada kategori yang selected di awal (empty string)
      // Agar user tidak bingung dan bisa memilih kategori sendiri
      const defaultCategoryId = '';
      final filteredStalls = allStalls; // Tampilkan semua kantin di awal

      emit(
        SiswaHomeLoaded(
          allStalls: allStalls,
          filteredStalls: filteredStalls,
          categories: categories,
          selectedCategoryId: defaultCategoryId,
        ),
      );
    } catch (e) {
      print('Error loading home: $e');
      emit(SiswaHomeError('Failed to load stalls: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshStalls(
    RefreshStallsEvent event,
    Emitter<SiswaHomeState> emit,
  ) async {
    if (state is! SiswaHomeLoaded) {
      emit(const SiswaHomeLoading());
    }

    try {
      final result = await getAllStansUseCase();
      final allStalls = result.fold(
        (failure) => throw Exception(failure.message),
        (stalls) => stalls,
      );

      if (allStalls.isEmpty) {
        emit(const SiswaHomeEmpty());
        return;
      }

      final currentState = state;
      final selectedCategoryId = currentState is SiswaHomeLoaded
          ? currentState.selectedCategoryId
          : '';
      final categories = currentState is SiswaHomeLoaded
          ? currentState.categories
          : <Category>[];

      final filteredStalls = selectedCategoryId.isNotEmpty
          ? _filterStallsByCategory(allStalls, selectedCategoryId)
          : allStalls;

      emit(
        SiswaHomeLoaded(
          allStalls: allStalls,
          filteredStalls: filteredStalls,
          categories: categories,
          selectedCategoryId: selectedCategoryId,
        ),
      );
    } catch (e) {
      emit(SiswaHomeError('Failed to refresh stalls: ${e.toString()}'));
    }
  }

  Future<void> _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<SiswaHomeState> emit,
  ) async {
    if (state is SiswaHomeLoaded) {
      final currentState = state as SiswaHomeLoaded;
      final filteredStalls = _filterStallsByCategory(
        currentState.allStalls,
        event.categoryId,
      );

      emit(
        currentState.copyWith(
          filteredStalls: filteredStalls,
          selectedCategoryId: event.categoryId,
        ),
      );
    }
  }

  Future<void> _onChangeBottomNav(
    ChangeBottomNavEvent event,
    Emitter<SiswaHomeState> emit,
  ) async {
    if (state is SiswaHomeLoaded) {
      final currentState = state as SiswaHomeLoaded;
      emit(currentState.copyWith(currentBottomNavIndex: event.index));
    }
  }

  List<Stan> _filterStallsByCategory(List<Stan> stalls, String categoryId) {
    return stalls.where((stall) {
      return stall.categories.any((cat) => cat == categoryId);
    }).toList();
  }

  Future<void> _onLoadLocation(
    LoadLocationEvent event,
    Emitter<SiswaHomeState> emit,
  ) async {
    if (state is SiswaHomeLoaded) {
      final currentState = state as SiswaHomeLoaded;

      try {
        print('Bloc: Loading location...');
        final locationDetails = await locationService
            .getCurrentLocationDetails();

        print(
          'Bloc: Location details received: ${locationDetails['city']} - ${locationDetails['address']}',
        );

        emit(
          currentState.copyWith(
            city: locationDetails['city'] ?? 'Lokasi',
            address: locationDetails['address'] ?? 'Alamat tidak tersedia',
          ),
        );

        print('Bloc: State emitted with new location');
      } catch (e) {
        print('Bloc: Error loading location: $e');
        // Keep current state if location fetch fails
        emit(
          currentState.copyWith(
            city: 'Lokasi tidak tersedia',
            address: 'Aktifkan lokasi untuk melihat alamat',
          ),
        );
      }
    } else {
      print(
        'Bloc: State is not SiswaHomeLoaded, current state: ${state.runtimeType}',
      );
    }
  }
}
