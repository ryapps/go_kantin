import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kantin_app/core/error/exceptions.dart';
import 'package:kantin_app/core/utils/constants.dart';

import '../models/category_model.dart';

abstract class CategoryRemoteDatasource {
  /// Get all active categories
  Future<List<CategoryModel>> getAllCategories();

  /// Get category by ID
  Future<CategoryModel> getCategoryById(String categoryId);

  /// Create new category
  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String imageUrl,
    int order = 0,
  });

  /// Update category
  Future<CategoryModel> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    String? imageUrl,
    int? order,
    bool? isActive,
  });

  /// Delete category
  Future<void> deleteCategory(String categoryId);

  /// Toggle category active status
  Future<void> toggleCategoryStatus(String categoryId, bool isActive);
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final FirebaseFirestore _firestore;

  CategoryRemoteDatasourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs.map(CategoryModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Gagal mengambil kategori: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .get();

      if (!snapshot.exists) {
        throw NotFoundException('Kategori tidak ditemukan');
      }

      return CategoryModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal mengambil kategori: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String imageUrl,
    int order = 0,
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.categoriesCollection)
          .doc();

      final categoryData = {
        'name': name,
        'icon': icon,
        'imageUrl': imageUrl,
        'order': order,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(categoryData);

      final snapshot = await docRef.get();
      return CategoryModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal membuat kategori: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    String? imageUrl,
    int? order,
    bool? isActive,
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId);

      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (icon != null) updates['icon'] = icon;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (order != null) updates['order'] = order;
      if (isActive != null) updates['isActive'] = isActive;

      if (updates.isEmpty) {
        throw ServerException('Tidak ada data yang diupdate');
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.update(updates);

      final snapshot = await docRef.get();
      return CategoryModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException('Gagal mengupdate kategori: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw ServerException('Gagal menghapus kategori: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw ServerException('Gagal mengubah status kategori: ${e.toString()}');
    }
  }
}
