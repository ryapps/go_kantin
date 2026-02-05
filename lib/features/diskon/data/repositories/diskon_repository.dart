import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';
import 'package:kantin_app/features/diskon/domain/entities/menu_diskon.dart';
import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository_new.dart';

import '../../../../core/error/failures.dart';
import '../datasources/diskon_datasource.dart';

class DiskonRepository implements IDiskonRepository {
  final DiskonRemoteDatasource _datasource;
  final FirebaseFirestore _firestore;

  DiskonRepository({
    required DiskonRemoteDatasource datasource,
    required FirebaseFirestore firestore,
  }) : _datasource = datasource,
       _firestore = firestore;

  @override
  Future<Either<Failure, Diskon>> createDiskon({
    required String stanId,
    required String namaDiskon,
    required double persentaseDiskon,
    required DateTime tanggalAwal,
    required DateTime tanggalAkhir,
  }) async {
    try {
      final diskonModel = await _datasource.createDiskon(
        stanId: stanId,
        namaDiskon: namaDiskon,
        persentaseDiskon: persentaseDiskon,
        tanggalAwal: tanggalAwal,
        tanggalAkhir: tanggalAkhir,
      );
      return Right(diskonModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Diskon>>> getDiskonsByStan(String stanId) async {
    try {
      final diskonModels = await _datasource.getDiskonsByStan(stanId);
      return Right(diskonModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Diskon>>> getActiveDiskonsByStan(
    String stanId,
  ) async {
    try {
      final diskonModels = await _datasource.getDiskonsByStan(
        stanId,
        activeOnly: true,
      );
      return Right(diskonModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Diskon>> getDiskonById(String diskonId) async {
    try {
      final diskonModel = await _datasource.getDiskonById(diskonId);
      return Right(diskonModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Diskon>> updateDiskon({
    required String diskonId,
    bool? isActive,
    String? namaDiskon,
    double? persentaseDiskon,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) async {
    try {
      final diskonModel = await _datasource.updateDiskon(
        diskonId: diskonId,
        namaDiskon: namaDiskon,
        persentaseDiskon: persentaseDiskon,
        tanggalAwal: tanggalAwal,
        tanggalAkhir: tanggalAkhir,
      );
      return Right(diskonModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> activateDiskon(String diskonId) async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateDiskon(String diskonId) async {
    try {
      await _datasource.updateDiskon(
        diskonId: diskonId,
        tanggalAkhir: DateTime.now().subtract(const Duration(days: 1)),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDiskon(String diskonId) async {
    try {
      await _datasource.deleteDiskon(diskonId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Menu-Diskon junction operations

  @override
  Future<Either<Failure, MenuDiskon>> assignDiskonToMenu(
    String menuId,
    String diskonId,
  ) async {
    try {
      // Create a menu-diskon link using the datasource
      await _datasource.linkDiskonToMenu(diskonId: diskonId, menuIds: [menuId]);

      // Create and return the MenuDiskon entity
      final menuDiskon = MenuDiskon(
        id: '', // Will be assigned by Firestore
        menuId: menuId,
        diskonId: diskonId,
        createdAt: DateTime.now(),
      );

      return Right(menuDiskon);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeDiskonFromMenu(String menuId) async {
    try {
      // First, get the diskon ID for this menu
      final diskonModel = await _datasource.getDiskonForMenu(menuId);

      if (diskonModel != null) {
        await _datasource.unlinkDiskonFromMenu(
          diskonId: diskonModel.id,
          menuIds: [menuId],
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getMenusWithDiskon(
    String diskonId,
  ) async {
    try {
      final menuIds = await _datasource.getMenuIdsWithDiskon(diskonId);
      return Right(menuIds);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> linkDiskonToMenu({
    required String diskonId,
    required List<String> menuIds,
  }) async {
    try {
      await _datasource.linkDiskonToMenu(diskonId: diskonId, menuIds: menuIds);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> unlinkDiskonFromMenu({
    required String diskonId,
    required List<String> menuIds,
  }) async {
    try {
      await _datasource.unlinkDiskonFromMenu(
        diskonId: diskonId,
        menuIds: menuIds,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<String>>> getMenuIdsWithDiskon(
    String diskonId,
  ) async {
    try {
      final menuIds = await _datasource.getMenuIdsWithDiskon(diskonId);
      return Right(menuIds);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Diskon?>> getDiskonForMenu(String menuId) async {
    try {
      final diskonModel = await _datasource.getDiskonForMenu(menuId);
      return Right(diskonModel?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Diskon>>> getActiveDiscountsForMenu(
    String menuId,
  ) async {
    try {
      final diskonModels = await _datasource.getActiveDiscountsForMenu(menuId);
      return Right(diskonModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
