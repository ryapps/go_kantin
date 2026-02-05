import 'package:equatable/equatable.dart';

abstract class AllCanteensEvent extends Equatable {
  const AllCanteensEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllCanteens extends AllCanteensEvent {
  const LoadAllCanteens();
}

class LoadMoreCanteens extends AllCanteensEvent {
  const LoadMoreCanteens();
}

class RefreshCanteens extends AllCanteensEvent {
  const RefreshCanteens();
}

class SearchCanteens extends AllCanteensEvent {
  final String query;

  const SearchCanteens(this.query);

  @override
  List<Object?> get props => [query];
}
