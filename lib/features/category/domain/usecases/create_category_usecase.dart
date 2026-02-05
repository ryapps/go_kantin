import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/category/domain/repositories/i_category_repository.dart';

class CreateCategoryUseCase implements UseCase<Category, CreateCategoryParams> {
  final ICategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(CreateCategoryParams params) async {
    return await repository.createCategory(
      name: params.name,
      icon: params.icon,
      imageUrl: params.imageUrl,
      order: params.order,
    );
  }
}

class CreateCategoryParams {
  final String name;
  final String icon;
  final String imageUrl;
  final int order;

  CreateCategoryParams({
    required this.name,
    required this.icon,
    required this.imageUrl,
    this.order = 0,
  });
}
