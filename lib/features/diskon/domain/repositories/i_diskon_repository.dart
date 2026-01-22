import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/menu_diskon.dart';

/// Diskon repository interface
abstract class IDiskonRepository {
  /// Create new discount
  Future<Either<Failure, Diskon>> createDiskon({
    required String namaDiskon,
    required double persentaseDiskon,
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
  });

  /// Get all discounts
  Future<Either<Failure, List<Diskon>>> getAllDiskon();

  /// Get active/valid discounts only
  Future<Either<Failure, List<Diskon>>> getActiveDiskon();

  /// Get discount by ID
  Future<Either<Failure, Diskon>> getDiskonById(String diskonId);

  /// Update discount
  Future<Either<Failure, Diskon>> updateDiskon({
    required String diskonId,
    String? namaDiskon,
    double? persentaseDiskon,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  });

  /// Activate discount
  Future<Either<Failure, void>> activateDiskon(String diskonId);

  /// Deactivate discount
  Future<Either<Failure, void>> deactivateDiskon(String diskonId);

  /// Delete discount
  Future<Either<Failure, void>> deleteDiskon(String diskonId);

  // Menu-Diskon junction operations

  /// Link discount to menu items
  Future<Either<Failure, void>> linkDiskonToMenu({
    required String diskonId,
    required List<String> menuIds,
  });

  /// Unlink discount from menu items
  Future<Either<Failure, void>> unlinkDiskonFromMenu({
    required String diskonId,
    required List<String> menuIds,
  });

  /// Get menu IDs that have a discount
  Future<Either<Failure, List<String>>> getMenuIdsWithDiskon(String diskonId);

  /// Get discount for a menu item (if any)
  Future<Either<Failure, Diskon?>> getDiskonForMenu(String menuId);

  /// Get all active discounts for a menu item
  Future<Either<Failure, List<Diskon>>> getActiveDiscountsForMenu(
    String menuId,
  );
}