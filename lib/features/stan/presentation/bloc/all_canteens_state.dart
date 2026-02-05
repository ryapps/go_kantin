import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';

abstract class AllCanteensState extends Equatable {
  const AllCanteensState();

  @override
  List<Object?> get props => [];
}

class AllCanteensInitial extends AllCanteensState {}

class AllCanteensLoading extends AllCanteensState {}

class AllCanteensLoaded extends AllCanteensState {
  final List<Stan> canteens;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? searchQuery;

  const AllCanteensLoaded({
    required this.canteens,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
    canteens,
    hasReachedMax,
    isLoadingMore,
    searchQuery,
  ];

  AllCanteensLoaded copyWith({
    List<Stan>? canteens,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? searchQuery,
  }) {
    return AllCanteensLoaded(
      canteens: canteens ?? this.canteens,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AllCanteensError extends AllCanteensState {
  final String message;

  const AllCanteensError(this.message);

  @override
  List<Object?> get props => [message];
}
