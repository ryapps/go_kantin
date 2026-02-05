import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/features/category/data/datasources/category_datasource.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/category/domain/repositories/i_category_repository.dart';

class CategoryRepository implements ICategoryRepository {
  final CategoryRemoteDatasource _datasource;
  final FirebaseFirestore _firestore;

  CategoryRepository({
    required CategoryRemoteDatasource datasource,
    required FirebaseFirestore firestore,
  }) : _datasource = datasource,
       _firestore = firestore;

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final categoryModels = await _datasource.getAllCategories();
      return Right(categoryModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String categoryId) async {
    try {
      final categoryModel = await _datasource.getCategoryById(categoryId);
      return Right(categoryModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required String icon,
    required String imageUrl,
    int order = 0,
  }) async {
    try {
      final categoryModel = await _datasource.createCategory(
        name: name,
        icon: icon,
        imageUrl: imageUrl,
        order: order,
      );
      return Right(categoryModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    String? imageUrl,
    int? order,
    bool? isActive,
  }) async {
    try {
      final categoryModel = await _datasource.updateCategory(
        categoryId: categoryId,
        name: name,
        icon: icon,
        imageUrl: imageUrl,
        order: order,
        isActive: isActive,
      );
      return Right(categoryModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await _datasource.deleteCategory(categoryId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCategoryStatus(
    String categoryId,
    bool isActive,
  ) async {
    try {
      await _datasource.toggleCategoryStatus(categoryId, isActive);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
