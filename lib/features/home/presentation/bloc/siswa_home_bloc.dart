import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_event.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_state.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';
import 'package:kantin_app/features/stan/domain/usecases/get_all_stans_usecase.dart';

class SiswaHomeBloc extends Bloc<SiswaHomeEvent, SiswaHomeState> {
  final GetAllStansUseCase getAllStansUseCase;

  SiswaHomeBloc({required this.getAllStansUseCase})
    : super(const SiswaHomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
    on<RefreshStallsEvent>(_onRefreshStalls);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<ChangeBottomNavEvent>(_onChangeBottomNav);
  }

  Future<void> _onLoadHome(
    LoadHomeEvent event,
    Emitter<SiswaHomeState> emit,
  ) async {
    emit(const SiswaHomeLoading());

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

      // Filter by default category
      final filteredStalls = _filterStallsByCategory(allStalls, 'aneka_nasi');

      emit(
        SiswaHomeLoaded(
          allStalls: allStalls,
          filteredStalls: filteredStalls,
          selectedCategoryId: 'aneka_nasi',
        ),
      );
    } catch (e) {
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
          : 'aneka_nasi';

      final filteredStalls = _filterStallsByCategory(
        allStalls,
        selectedCategoryId,
      );

      emit(
        SiswaHomeLoaded(
          allStalls: allStalls,
          filteredStalls: filteredStalls,
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
    final selectedCategory = Category.all.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category.anekaNasi,
    );

    return stalls.where((stall) {
      return stall.categories.any((cat) => cat == selectedCategory.id);
    }).toList();
  }
}
