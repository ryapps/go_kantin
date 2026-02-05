import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/category/domain/repositories/i_category_repository.dart';

class GetAllCategoriesUseCase implements UseCaseNoParams<List<Category>> {
  final ICategoryRepository repository;

  GetAllCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call() async {
    return await repository.getAllCategories();
  }
}
