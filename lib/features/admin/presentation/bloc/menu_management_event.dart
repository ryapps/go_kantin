import 'package:equatable/equatable.dart';

abstract class MenuManagementEvent extends Equatable {
  const MenuManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuItems extends MenuManagementEvent {
  final String stanId;

  const LoadMenuItems(this.stanId);

  @override
  List<Object?> get props => [stanId];
}

class AddMenuItem extends MenuManagementEvent {
  final String stanId;
  final String namaItem;
  final double harga;
  final String jenis;
  final String fotoPath;
  final String deskripsi;

  const AddMenuItem({
    required this.stanId,
    required this.namaItem,
    required this.harga,
    required this.jenis,
    required this.fotoPath,
    required this.deskripsi,
  });

  @override
  List<Object?> get props => [
    stanId,
    namaItem,
    harga,
    jenis,
    fotoPath,
    deskripsi,
  ];
}

class UpdateMenuItem extends MenuManagementEvent {
  final String menuId;
  final String namaItem;
  final double harga;
  final String jenis;
  final String? fotoPath;
  final String deskripsi;

  const UpdateMenuItem({
    required this.menuId,
    required this.namaItem,
    required this.harga,
    required this.jenis,
    this.fotoPath,
    required this.deskripsi,
  });

  @override
  List<Object?> get props => [
    menuId,
    namaItem,
    harga,
    jenis,
    fotoPath,
    deskripsi,
  ];
}

class DeleteMenuItem extends MenuManagementEvent {
  final String menuId;

  const DeleteMenuItem(this.menuId);

  @override
  List<Object?> get props => [menuId];
}

class ToggleMenuAvailability extends MenuManagementEvent {
  final String menuId;
  final bool isAvailable;

  const ToggleMenuAvailability(this.menuId, this.isAvailable);

  @override
  List<Object?> get props => [menuId, isAvailable];
}

class PickMenuImage extends MenuManagementEvent {
  const PickMenuImage();
}

class FilterMenuByType extends MenuManagementEvent {
  final String? jenis; // null = all, 'makanan', 'minuman'

  const FilterMenuByType(this.jenis);

  @override
  List<Object?> get props => [jenis];
}

class SearchMenuItems extends MenuManagementEvent {
  final String query;

  const SearchMenuItems(this.query);

  @override
  List<Object?> get props => [query];
}
