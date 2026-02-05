import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';
import 'package:kantin_app/features/diskon/domain/entities/menu_diskon.dart';

abstract class IDiskonRepository {
  /// Create new diskon
  Future<Either<Failure, Diskon>> createDiskon({
    required String stanId,
    required String namaDiskon,
    required double persentaseDiskon,
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
  });

  /// Get all diskons by stan
  Future<Either<Failure, List<Diskon>>> getDiskonsByStan(String stanId);

  /// Get active diskons by stan
  Future<Either<Failure, List<Diskon>>> getActiveDiskonsByStan(String stanId);

  /// Get diskon by ID
  Future<Either<Failure, Diskon>> getDiskonById(String diskonId);

  /// Update diskon
  Future<Either<Failure, Diskon>> updateDiskon({
    required String diskonId,
    String? namaDiskon,
    double? persentaseDiskon,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
    bool? isActive,
  });

  /// Delete diskon
  Future<Either<Failure, void>> deleteDiskon(String diskonId);

  /// Assign diskon to menu
  Future<Either<Failure, MenuDiskon>> assignDiskonToMenu(
    String menuId,
    String diskonId,
  );

  /// Remove diskon from menu
  Future<Either<Failure, void>> removeDiskonFromMenu(String menuId);

  /// Get diskon for menu
  Future<Either<Failure, Diskon?>> getDiskonForMenu(String menuId);

  /// Get all menus with this diskon
  Future<Either<Failure, List<String>>> getMenusWithDiskon(String diskonId);
}
