import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';

abstract class ICategoryRepository {
  /// Get all active categories
  Future<Either<Failure, List<Category>>> getAllCategories();

  /// Get category by ID
  Future<Either<Failure, Category>> getCategoryById(String categoryId);

  /// Create new category
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required String icon,
    required String imageUrl,
    int order = 0,
  });

  /// Update category
  Future<Either<Failure, Category>> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    String? imageUrl,
    int? order,
    bool? isActive,
  });

  /// Delete category
  Future<Either<Failure, void>> deleteCategory(String categoryId);

  /// Toggle category active status
  Future<Either<Failure, void>> toggleCategoryStatus(
    String categoryId,
    bool isActive,
  );
}
