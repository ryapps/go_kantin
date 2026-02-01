import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';

abstract class MenuManagementState extends Equatable {
  const MenuManagementState();

  @override
  List<Object?> get props => [];
}

class MenuManagementInitial extends MenuManagementState {}

class MenuManagementLoading extends MenuManagementState {}

class MenuManagementLoaded extends MenuManagementState {
  final List<Menu> menus;
  final List<Menu> filteredMenus;
  final String? currentFilter; // null, 'makanan', 'minuman'
  final String? searchQuery;

  const MenuManagementLoaded({
    required this.menus,
    required this.filteredMenus,
    this.currentFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [menus, filteredMenus, currentFilter, searchQuery];

  MenuManagementLoaded copyWith({
    List<Menu>? menus,
    List<Menu>? filteredMenus,
    String? currentFilter,
    String? searchQuery,
  }) {
    return MenuManagementLoaded(
      menus: menus ?? this.menus,
      filteredMenus: filteredMenus ?? this.filteredMenus,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class MenuManagementOperating extends MenuManagementState {
  final List<Menu> menus;
  final String operation; // 'adding', 'updating', 'deleting', 'toggling'

  const MenuManagementOperating(this.menus, this.operation);

  @override
  List<Object?> get props => [menus, operation];
}

class MenuManagementSuccess extends MenuManagementState {
  final List<Menu> menus;
  final String message;

  const MenuManagementSuccess(this.menus, this.message);

  @override
  List<Object?> get props => [menus, message];
}

class MenuManagementError extends MenuManagementState {
  final String message;

  const MenuManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

class MenuImagePicked extends MenuManagementState {
  final String imagePath;

  const MenuImagePicked(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}
