import 'package:equatable/equatable.dart';

abstract class CategoryManagementEvent extends Equatable {
  const CategoryManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllCategoriesEvent extends CategoryManagementEvent {}

class RefreshCategoriesEvent extends CategoryManagementEvent {}

class CreateCategoryEvent extends CategoryManagementEvent {
  final String name;
  final String icon;
  final String imageUrl;
  final int order;

  const CreateCategoryEvent({
    required this.name,
    required this.icon,
    required this.imageUrl,
    this.order = 0,
  });

  @override
  List<Object?> get props => [name, icon, imageUrl, order];
}

class UpdateCategoryEvent extends CategoryManagementEvent {
  final String categoryId;
  final String name;
  final String icon;
  final String imageUrl;
  final int order;
  final bool isActive;

  const UpdateCategoryEvent({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.order,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    categoryId,
    name,
    icon,
    imageUrl,
    order,
    isActive,
  ];
}
