import 'package:equatable/equatable.dart';
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
  final String selectedCategoryId;
  final int currentBottomNavIndex;

  const SiswaHomeLoaded({
    required this.allStalls,
    required this.filteredStalls,
    required this.selectedCategoryId,
    this.currentBottomNavIndex = 0,
  });

  SiswaHomeLoaded copyWith({
    List<Stan>? allStalls,
    List<Stan>? filteredStalls,
    String? selectedCategoryId,
    int? currentBottomNavIndex,
  }) {
    return SiswaHomeLoaded(
      allStalls: allStalls ?? this.allStalls,
      filteredStalls: filteredStalls ?? this.filteredStalls,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      currentBottomNavIndex:
          currentBottomNavIndex ?? this.currentBottomNavIndex,
    );
  }

  @override
  List<Object> get props => [
    allStalls,
    filteredStalls,
    selectedCategoryId,
    currentBottomNavIndex,
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
