import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/category/domain/repositories/i_category_repository.dart';

class UpdateCategoryUseCase implements UseCase<Category, UpdateCategoryParams> {
  final ICategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(
      categoryId: params.categoryId,
      name: params.name,
      icon: params.icon,
      imageUrl: params.imageUrl,
      order: params.order,
      isActive: params.isActive,
    );
  }
}

class UpdateCategoryParams {
  final String categoryId;
  final String name;
  final String icon;
  final String imageUrl;
  final int order;
  final bool isActive;

  UpdateCategoryParams({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.order,
    required this.isActive,
  });
}
