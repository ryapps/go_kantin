import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/features/category/domain/usecases/create_category_usecase.dart';
import 'package:kantin_app/features/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:kantin_app/features/category/domain/usecases/update_category_usecase.dart';

import 'category_management_event.dart';
import 'category_management_state.dart';

class CategoryManagementBloc
    extends Bloc<CategoryManagementEvent, CategoryManagementState> {
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;

  CategoryManagementBloc({
    required GetAllCategoriesUseCase getAllCategoriesUseCase,
    required CreateCategoryUseCase createCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
  }) : _getAllCategoriesUseCase = getAllCategoriesUseCase,
       _createCategoryUseCase = createCategoryUseCase,
       _updateCategoryUseCase = updateCategoryUseCase,
       super(CategoryManagementInitial()) {
    on<LoadAllCategoriesEvent>(_onLoadAllCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<RefreshCategoriesEvent>(_onRefreshCategories);
    on<UpdateCategoryEvent>(_onUpdateCategory);
  }

  Future<void> _onLoadAllCategories(
    LoadAllCategoriesEvent event,
    Emitter<CategoryManagementState> emit,
  ) async {
    emit(CategoryManagementLoading());

    final result = await _getAllCategoriesUseCase();

    result.fold(
      (failure) => emit(CategoryManagementError(failure.message)),
      (categories) => emit(CategoryManagementLoaded(categories)),
    );
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryManagementState> emit,
  ) async {
    emit(CategoryManagementLoading());

    final result = await _createCategoryUseCase(
      CreateCategoryParams(
        name: event.name,
        icon: event.icon,
        imageUrl: event.imageUrl,
        order: event.order,
      ),
    );

    result.fold((failure) => emit(CategoryManagementError(failure.message)), (
      category,
    ) {
      // Reload categories after creating
      add(LoadAllCategoriesEvent());
      emit(CategoryCreatedSuccess(category));
    });
  }

  Future<void> _onRefreshCategories(
    RefreshCategoriesEvent event,
    Emitter<CategoryManagementState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await _getAllCategoriesUseCase();

    result.fold(
      (failure) => emit(CategoryManagementError(failure.message)),
      (categories) => emit(CategoryManagementLoaded(categories)),
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryManagementState> emit,
  ) async {
    emit(CategoryManagementLoading());

    final result = await _updateCategoryUseCase(
      UpdateCategoryParams(
        categoryId: event.categoryId,
        name: event.name,
        icon: event.icon,
        imageUrl: event.imageUrl,
        order: event.order,
        isActive: event.isActive,
      ),
    );

    result.fold((failure) => emit(CategoryManagementError(failure.message)), (
      category,
    ) {
      add(LoadAllCategoriesEvent());
      emit(CategoryUpdatedSuccess(category));
    });
  }
}
