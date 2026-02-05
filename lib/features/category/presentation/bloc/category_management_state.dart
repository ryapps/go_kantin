import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';

abstract class CategoryManagementState extends Equatable {
  const CategoryManagementState();

  @override
  List<Object?> get props => [];
}

class CategoryManagementInitial extends CategoryManagementState {}

class CategoryManagementLoading extends CategoryManagementState {}

class CategoryManagementLoaded extends CategoryManagementState {
  final List<Category> categories;

  const CategoryManagementLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryCreatedSuccess extends CategoryManagementState {
  final Category category;

  const CategoryCreatedSuccess(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryUpdatedSuccess extends CategoryManagementState {
  final Category category;

  const CategoryUpdatedSuccess(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryManagementError extends CategoryManagementState {
  final String message;

  const CategoryManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
