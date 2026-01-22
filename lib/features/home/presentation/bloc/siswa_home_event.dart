import 'package:equatable/equatable.dart';

abstract class SiswaHomeEvent extends Equatable {
  const SiswaHomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeEvent extends SiswaHomeEvent {
  const LoadHomeEvent();
}

class RefreshStallsEvent extends SiswaHomeEvent {
  const RefreshStallsEvent();
}

class SelectCategoryEvent extends SiswaHomeEvent {
  final String categoryId;

  const SelectCategoryEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class ChangeBottomNavEvent extends SiswaHomeEvent {
  final int index;

  const ChangeBottomNavEvent(this.index);

  @override
  List<Object> get props => [index];
}
