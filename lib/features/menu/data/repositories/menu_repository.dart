import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/menu.dart';
import '../../domain/repositories/i_menu_repository.dart';
import '../datasources/menu_datasource.dart';

class MenuRepository implements IMenuRepository {
  final MenuRemoteDatasource _datasource;
  final FirebaseFirestore _firestore;

  MenuRepository({
    required MenuRemoteDatasource datasource,
    required FirebaseFirestore firestore,
  })  : _datasource = datasource,
        _firestore = firestore;

  @override
  Future<Either<Failure, Menu>> createMenu({
    required String stanId,
    required String namaMakanan,
    required double harga,
    required String jenis,
    required String fotoPath,
    required String deskripsi,
  }) async {
    try {
      final menuModel = await _datasource.createMenu(
        stanId: stanId,
        namaMakanan: namaMakanan,
        harga: harga,
        jenis: jenis,
        fotoPath: fotoPath,
        deskripsi: deskripsi,
      );
      return Right(menuModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Menu>>> getAllMenu() async {
    try {
      final menuModels = await _datasource.getAllMenu();
      return Right(menuModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Menu>>> getMenuByStanId(String stanId) async {
    try {
      final menuModels = await _datasource.getMenuByStanId(stanId);
      return Right(menuModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Menu>> getMenuById(String menuId) async {
    try {
      final menuModel = await _datasource.getMenuById(menuId);
      return Right(menuModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Menu>>> searchMenu(String query) async {
    try {
      final menuModels = await _datasource.searchMenu(query);
      return Right(menuModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Menu>>> filterMenuByType(String jenis) async {
    try {
      final menuModels = await _datasource.filterMenuByType(jenis);
      return Right(menuModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Menu>> updateMenu({
    required String menuId,
    String? namaMakanan,
    double? harga,
    String? jenis,
    String? fotoPath,
    String? deskripsi,
  }) async {
    try {
      final menuModel = await _datasource.updateMenu(
        menuId: menuId,
        namaMakanan: namaMakanan,
        harga: harga,
        jenis: jenis,
        fotoPath: fotoPath,
        deskripsi: deskripsi,
      );
      return Right(menuModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAvailability(
    String menuId,
    bool isAvailable,
  ) async {
    try {
      await _datasource.toggleAvailability(menuId, isAvailable);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMenu(String menuId) async {
    try {
      await _datasource.deleteMenu(menuId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Menu>>> watchAllMenu() {
    try {
      return _datasource.watchAllMenu().map<Either<Failure, List<Menu>>>(
        (menuModels) => Right(
          menuModels.map((model) => model.toEntity()).toList(),
        ),
      ).handleError((e) => Left<Failure, List<Menu>>(ServerFailure(e.toString())));
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<Menu>>> watchMenuByStanId(String stanId) {
    try {
      return _datasource.watchMenuByStanId(stanId).map<Either<Failure, List<Menu>>>(
        (menuModels) => Right(
          menuModels.map((model) => model.toEntity()).toList(),
        ),
      ).handleError((e) => Left<Failure, List<Menu>>(ServerFailure(e.toString())));
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Menu>>> getCachedMenu() async {
    // Implementation for caching will go here
    return const Left(CacheFailure('Cache not implemented'));
  }

  @override
  Future<Either<Failure, void>> cacheMenu(List<Menu> menus) async {
    // Implementation for caching will go here
    return const Left(CacheFailure('Cache not implemented'));
  }

  @override
  Future<bool> isCacheValid() async {
    // Implementation for caching will go here
    return false;
  }
}