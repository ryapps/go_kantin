import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_state.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';
import 'package:kantin_app/features/menu/domain/repositories/i_menu_repository.dart';

class MenuManagementBloc
    extends Bloc<MenuManagementEvent, MenuManagementState> {
  final IMenuRepository menuRepository;
  final ImagePicker _imagePicker = ImagePicker();

  MenuManagementBloc({required this.menuRepository})
    : super(MenuManagementInitial()) {
    on<LoadMenuItems>(_onLoadMenuItems);
    on<AddMenuItem>(_onAddMenuItem);
    on<UpdateMenuItem>(_onUpdateMenuItem);
    on<DeleteMenuItem>(_onDeleteMenuItem);
    on<ToggleMenuAvailability>(_onToggleMenuAvailability);
    on<PickMenuImage>(_onPickMenuImage);
    on<FilterMenuByType>(_onFilterMenuByType);
    on<SearchMenuItems>(_onSearchMenuItems);
  }

  Future<void> _onLoadMenuItems(
    LoadMenuItems event,
    Emitter<MenuManagementState> emit,
  ) async {
    emit(MenuManagementLoading());

    final result = await menuRepository.getMenuByStanId(event.stanId);

    result.fold(
      (failure) => emit(MenuManagementError(failure.message)),
      (menus) => emit(MenuManagementLoaded(menus: menus, filteredMenus: menus)),
    );
  }

  Future<void> _onAddMenuItem(
    AddMenuItem event,
    Emitter<MenuManagementState> emit,
  ) async {
    emit(MenuManagementLoading());

    final result = await menuRepository.createMenu(
      stanId: event.stanId,
      namaMakanan: event.namaItem,
      harga: event.harga,
      jenis: event.jenis,
      fotoPath: event.fotoPath,
      deskripsi: event.deskripsi,
    );

    result.fold(
      (failure) => emit(MenuManagementError(failure.message)),
      (newMenu) {
        // After successful creation, reload all menu items to ensure data consistency
        emit(const MenuManagementSuccess([], 'Menu berhasil ditambahkan'));
        add(LoadMenuItems(event.stanId)); // Trigger a reload of menu items
      }
    );
  }

  Future<void> _onUpdateMenuItem(
    UpdateMenuItem event,
    Emitter<MenuManagementState> emit,
  ) async {
    emit(MenuManagementLoading());

    final result = await menuRepository.updateMenu(
      menuId: event.menuId,
      namaMakanan: event.namaItem,
      harga: event.harga,
      jenis: event.jenis,
      fotoPath: event.fotoPath,
      deskripsi: event.deskripsi,
    );

    result.fold(
      (failure) => emit(MenuManagementError(failure.message)),
      (updatedMenu) {
        // After successful update, reload all menu items to ensure data consistency
        emit(const MenuManagementSuccess([], 'Menu berhasil diperbarui'));
        // Get the stanId from the updated menu to reload the correct menu list
        add(LoadMenuItems(updatedMenu.stanId)); // Trigger a reload of menu items
      }
    );
  }

  Future<void> _onDeleteMenuItem(
    DeleteMenuItem event,
    Emitter<MenuManagementState> emit,
  ) async {
    // Get the current state to access the stanId
    final currentState = state;
    String stanId = '';

    if (currentState is MenuManagementLoaded) {
      // Find the menu to be deleted to get its stanId
      final menuToDelete = currentState.menus.firstWhere((m) => m.id == event.menuId, orElse: () => currentState.menus.first);
      stanId = menuToDelete.stanId;
    }

    emit(MenuManagementLoading());

    final result = await menuRepository.deleteMenu(event.menuId);

    result.fold(
      (failure) => emit(MenuManagementError(failure.message)),
      (_) {
        // After successful deletion, reload all menu items to ensure data consistency
        emit(const MenuManagementSuccess([], 'Menu berhasil dihapus'));
        add(LoadMenuItems(stanId)); // Trigger a reload of menu items
      }
    );
  }

  Future<void> _onToggleMenuAvailability(
    ToggleMenuAvailability event,
    Emitter<MenuManagementState> emit,
  ) async {
    // Get the current state to access the stanId
    final currentState = state;
    String stanId = '';

    if (currentState is MenuManagementLoaded) {
      // Find the menu to be toggled to get its stanId
      final menuToToggle = currentState.menus.firstWhere((m) => m.id == event.menuId, orElse: () => currentState.menus.first);
      stanId = menuToToggle.stanId;
    }

    emit(MenuManagementLoading());

    final result = await menuRepository.toggleAvailability(
      event.menuId,
      event.isAvailable,
    );

    result.fold(
      (failure) => emit(MenuManagementError(failure.message)),
      (_) {
        // After successful toggle, reload all menu items to ensure data consistency
        emit(const MenuManagementSuccess([], 'Status menu berhasil diubah'));
        add(LoadMenuItems(stanId)); // Trigger a reload of menu items
      }
    );
  }

  Future<void> _onPickMenuImage(
    PickMenuImage event,
    Emitter<MenuManagementState> emit,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        emit(MenuImagePicked(image.path));
      }
    } catch (e) {
      emit(MenuManagementError('Gagal memilih gambar: ${e.toString()}'));
    }
  }

  void _onFilterMenuByType(
    FilterMenuByType event,
    Emitter<MenuManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! MenuManagementLoaded) return;

    final filteredMenus = _applyFilters(
      currentState.menus,
      event.jenis,
      currentState.searchQuery,
    );

    emit(
      MenuManagementLoaded(
        menus: currentState.menus,
        filteredMenus: filteredMenus,
        currentFilter: event.jenis,
        searchQuery: currentState.searchQuery,
      ),
    );
  }

  void _onSearchMenuItems(
    SearchMenuItems event,
    Emitter<MenuManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! MenuManagementLoaded) return;

    final filteredMenus = _applyFilters(
      currentState.menus,
      currentState.currentFilter,
      event.query,
    );

    emit(
      MenuManagementLoaded(
        menus: currentState.menus,
        filteredMenus: filteredMenus,
        currentFilter: currentState.currentFilter,
        searchQuery: event.query,
      ),
    );
  }

  List<Menu> _applyFilters(
    List<Menu> menus,
    String? typeFilter,
    String? searchQuery,
  ) {
    var filtered = menus;

    // Apply type filter
    if (typeFilter != null) {
      filtered = filtered.where((m) => m.jenis == typeFilter).toList();
    }

    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (m) => m.namaItem.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }
}
