import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:kantin_app/features/admin/data/datasources/dashboard_remote_datasource.dart';
import 'package:kantin_app/features/transaksi/data/models/detail_transaksi_model.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaksi.dart';
import '../../domain/repositories/i_transaksi_repository.dart';
import '../datasources/transaksi_datasource.dart';

class TransaksiRepository implements ITransaksiRepository {
  final TransaksiRemoteDatasource _datasource;
  final FirebaseFirestore _firestore;
  final IDashboardRemoteDataSource? _dashboardDataSource;

  TransaksiRepository({
    required TransaksiRemoteDatasource datasource,
    required FirebaseFirestore firestore,
    IDashboardRemoteDataSource? dashboardDataSource,
  })  : _datasource = datasource,
        _firestore = firestore,
        _dashboardDataSource = dashboardDataSource;

  @override
  Future<Either<Failure, Transaksi>> placeOrder({
    required String siswaId,
    required String stanId,
    required List<DetailTransaksi> items,
  }) async {
    try {
      // Convert domain entities to data models
      final detailModels = items.map((detail) => DetailTransaksiModel.fromEntity(detail)).toList();
      final transaksiModel = await _datasource.placeOrder(
        siswaId: siswaId,
        stanId: stanId,
        items: detailModels,
      );

      // Update dashboard when a new order is placed
      if (_dashboardDataSource != null) {
        try {
          // Refresh dashboard data for the associated stan
          await _dashboardDataSource!.refreshDashboardData(stanId);
        } catch (e) {
          // Log the error but don't fail the order placement
          print('Failed to update dashboard after new order: $e');
        }
      }

      return Right(transaksiModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaksi>> getTransaksiById(String transaksiId) async {
    try {
      final transaksiModel = await _datasource.getTransaksiById(transaksiId);
      return Right(transaksiModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaksi>>> getTransaksiByStudent(String siswaId) async {
    try {
      final transaksiModels = await _datasource.getTransaksiByStudent(siswaId);
      return Right(transaksiModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaksi>>> getTransaksiByStan(String stanId) async {
    try {
      final transaksiModels = await _datasource.getTransaksiByStan(stanId);
      return Right(transaksiModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaksi>>> getAllTransaksi() async {
    try {
      final transaksiModels = await _datasource.getAllTransaksi();
      return Right(transaksiModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaksi>> updateTransaksiStatus({
    required String transaksiId,
    required String newStatus,
  }) async {
    try {
      final transaksiModel = await _datasource.updateTransaksiStatus(
        transaksiId: transaksiId,
        newStatus: newStatus,
      );

      // Update dashboard when transaction status changes
      if (_dashboardDataSource != null) {
        try {
          // Get the transaction to get the stanId
          final transaksi = transaksiModel.toEntity();
          // Refresh dashboard data for the associated stan
          await _dashboardDataSource!.refreshDashboardData(transaksi.stanId);
        } catch (e) {
          // Log the error but don't fail the transaction update
          print('Failed to update dashboard after transaction status change: $e');
        }
      }

      return Right(transaksiModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelTransaksi(String transaksiId) async {
    try {
      // Get the transaction before cancelling to get the stanId
      final transaksi = await getTransaksiById(transaksiId);

      await _datasource.cancelTransaksi(transaksiId);

      // Update dashboard when transaction is cancelled
      if (_dashboardDataSource != null && transaksi.isRight()) {
        try {
          // Refresh dashboard data for the associated stan
          await _dashboardDataSource.refreshDashboardData(
            transaksi.getOrElse(() => throw Exception('Transaksi not found')).stanId
          );
        } catch (e) {
          // Log the error but don't fail the cancellation
          print('Failed to update dashboard after transaction cancellation: $e');
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Transaksi>>> watchTransaksiByStudent(String siswaId) {
    return _datasource.watchTransaksiByStudent(siswaId).map(
      (transaksiModels) => Right<Failure, List<Transaksi>>(
        transaksiModels.map((model) => model.toEntity()).toList(),
      ),
    ).handleError((e) {
      return Left<Failure, List<Transaksi>>(ServerFailure(e.toString()));
    });
  }

  @override
  Stream<Either<Failure, List<Transaksi>>> watchTransaksiByStan(String stanId) {
    return _datasource.watchTransaksiByStan(stanId).map(
      (transaksiModels) => Right<Failure, List<Transaksi>>(
        transaksiModels.map((model) => model.toEntity()).toList(),
      ),
    ).handleError((e) {
      return Left<Failure, List<Transaksi>>(ServerFailure(e.toString()));
    });
  }

  @override
  Stream<Either<Failure, Transaksi>> watchTransaksiById(String transaksiId) {
    return _datasource.watchTransaksiById(transaksiId).map(
      (transaksiModel) => Right<Failure, Transaksi>(transaksiModel.toEntity()),
    ).handleError((e) {
      return Left<Failure, Transaksi>(ServerFailure(e.toString()));
    });
  }

  @override
  Future<Either<Failure, void>> queueOfflineOrder({
    required String siswaId,
    required String stanId,
    required List<DetailTransaksi> items,
  }) async {
    try {
      // Convert domain entities to data models
      final detailModels = items.map((detail) => DetailTransaksiModel.fromEntity(detail)).toList();
      await _datasource.queueOfflineOrder(
        siswaId: siswaId,
        stanId: stanId,
        items: detailModels,
      );

      // Update dashboard when an offline order is queued
      if (_dashboardDataSource != null) {
        try {
          // Refresh dashboard data for the associated stan
          await _dashboardDataSource!.refreshDashboardData(stanId);
        } catch (e) {
          // Log the error but don't fail the order queuing
          print('Failed to update dashboard after offline order: $e');
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOfflineOrders() async {
    try {
      final offlineOrders = await _datasource.getOfflineOrders();
      return Right(offlineOrders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaksi>>> syncOfflineOrders() async {
    try {
      final transaksiModels = await _datasource.syncOfflineOrders();

      // Update dashboard when offline orders are synced
      if (_dashboardDataSource != null && transaksiModels.isNotEmpty) {
        try {
          // Get the first transaction's stanId to update dashboard
          // In a real scenario, we might need to update multiple stans if orders are from different stans
          final stanId = transaksiModels.firstOrNull?.stanId ?? '';
          if (stanId.isNotEmpty) {
            await _dashboardDataSource!.refreshDashboardData(stanId);
          }
        } catch (e) {
          // Log the error but don't fail the sync
          print('Failed to update dashboard after syncing offline orders: $e');
        }
      }

      return Right(transaksiModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearOfflineOrder(String localOrderId) async {
    try {
      await _datasource.clearOfflineOrder(localOrderId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}