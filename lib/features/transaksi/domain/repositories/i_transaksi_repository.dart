import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaksi.dart';

/// Transaksi repository interface
abstract class ITransaksiRepository {
  /// Place new order (creates transaksi with details)
  Future<Either<Failure, Transaksi>> placeOrder({
    required String siswaId,
    required String stanId,
    required List<DetailTransaksi> items,
  });

  /// Get transaksi by ID
  Future<Either<Failure, Transaksi>> getTransaksiById(String transaksiId);

  /// Get all transaksi for a student
  Future<Either<Failure, List<Transaksi>>> getTransaksiByStudent(
    String siswaId,
  );

  /// Get all transaksi for a stan (stall owner view)
  Future<Either<Failure, List<Transaksi>>> getTransaksiByStan(
    String stanId,
  );

  /// Get all transaksi (super admin view)
  Future<Either<Failure, List<Transaksi>>> getAllTransaksi();

  /// Update transaksi status
  Future<Either<Failure, Transaksi>> updateTransaksiStatus({
    required String transaksiId,
    required String newStatus,
  });

  /// Cancel transaksi (only if status is belum_dikonfirm)
  Future<Either<Failure, void>> cancelTransaksi(String transaksiId);

  /// Stream transaksi by student (for real-time updates)
  Stream<Either<Failure, List<Transaksi>>> watchTransaksiByStudent(
    String siswaId,
  );

  /// Stream transaksi by stan (for real-time order queue)
  Stream<Either<Failure, List<Transaksi>>> watchTransaksiByStan(
    String stanId,
  );

  /// Stream single transaksi (for order tracking)
  Stream<Either<Failure, Transaksi>> watchTransaksiById(String transaksiId);

  // Offline operations
  
  /// Queue order for offline sync
  Future<Either<Failure, void>> queueOfflineOrder({
    required String siswaId,
    required String stanId,
    required List<DetailTransaksi> items,
  });

  /// Get all queued offline orders
  Future<Either<Failure, List<Map<String, dynamic>>>> getOfflineOrders();

  /// Sync queued orders when back online
  Future<Either<Failure, List<Transaksi>>> syncOfflineOrders();

  /// Clear offline order after successful sync
  Future<Either<Failure, void>> clearOfflineOrder(String localOrderId);
}