import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';

abstract class SiswaHomeState extends Equatable {
  const SiswaHomeState();

  @override
  List<Object> get props => [];
}

class SiswaHomeInitial extends SiswaHomeState {
  const SiswaHomeInitial();
}

class SiswaHomeLoading extends SiswaHomeState {
  const SiswaHomeLoading();
}

class SiswaHomeLoaded extends SiswaHomeState {
  final List<Stan> allStalls;
  final List<Stan> filteredStalls;
  final List<Category> categories;
  final String selectedCategoryId;
  final int currentBottomNavIndex;
  final String city;
  final String address;

  const SiswaHomeLoaded({
    required this.allStalls,
    required this.filteredStalls,
    required this.categories,
    required this.selectedCategoryId,
    this.currentBottomNavIndex = 0,
    this.city = 'Lokasi',
    this.address = 'Memuat lokasi...',
  });

  SiswaHomeLoaded copyWith({
    List<Stan>? allStalls,
    List<Stan>? filteredStalls,
    List<Category>? categories,
    String? selectedCategoryId,
    int? currentBottomNavIndex,
    String? city,
    String? address,
  }) {
    return SiswaHomeLoaded(
      allStalls: allStalls ?? this.allStalls,
      filteredStalls: filteredStalls ?? this.filteredStalls,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      currentBottomNavIndex:
          currentBottomNavIndex ?? this.currentBottomNavIndex,
      city: city ?? this.city,
      address: address ?? this.address,
    );
  }

  @override
  List<Object> get props => [
    allStalls,
    filteredStalls,
    categories,
    selectedCategoryId,
    currentBottomNavIndex,
    city,
    address,
  ];
}

class SiswaHomeError extends SiswaHomeState {
  final String message;

  const SiswaHomeError(this.message);

  @override
  List<Object> get props => [message];
}

class SiswaHomeEmpty extends SiswaHomeState {
  const SiswaHomeEmpty();
}
