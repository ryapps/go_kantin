import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/utils/constants.dart';
import 'package:kantin_app/features/admin/data/models/dashboard_data_model.dart';

abstract class IDashboardRemoteDataSource {
  /// Get dashboard summary for a specific stan
  Future<DashboardDataModel> getDashboardSummary(String stanId);

  /// Update dashboard data for a specific stan
  Future<DashboardDataModel> updateDashboardData(DashboardDataModel dashboardData);

  /// Refresh dashboard data based on latest transactions
  Future<DashboardDataModel> refreshDashboardData(String stanId);
}

class DashboardRemoteDataSource implements IDashboardRemoteDataSource {
  final FirebaseFirestore firestore;

  DashboardRemoteDataSource({required this.firestore});

  @override
  Future<DashboardDataModel> getDashboardSummary(String stanId) async {
    try {
      final docSnapshot = await firestore
          .collection(AppConstants.dashboardCollection)
          .doc(stanId)
          .get();

      if (docSnapshot.exists) {
        return DashboardDataModel.fromFirestore(
          docSnapshot.data()!,
          docSnapshot.id,
        );
      } else {
        // If no dashboard data exists, create a default one
        final defaultData = DashboardDataModel.empty(stanId);
        await firestore
            .collection(AppConstants.dashboardCollection)
            .doc(stanId)
            .set(defaultData.toFirestore());
        return defaultData;
      }
    } catch (e) {
      throw ServerFailure('Gagal mengambil data dashboard: ${e.toString()}');
    }
  }

  @override
  Future<DashboardDataModel> updateDashboardData(
    DashboardDataModel dashboardData,
  ) async {
    try {
      await firestore
          .collection(AppConstants.dashboardCollection)
          .doc(dashboardData.stanId)
          .set(dashboardData.toFirestore(), SetOptions(merge: true));

      // Return updated data
      return getDashboardSummary(dashboardData.stanId);
    } catch (e) {
      throw ServerFailure('Gagal memperbarui data dashboard: ${e.toString()}');
    }
  }

  @override
  Future<DashboardDataModel> refreshDashboardData(String stanId) async {
    try {
      // In a real implementation, this would recalculate all dashboard metrics
      // based on the latest data from transactions, menu, and customer collections
      
      // For now, let's get the current data and return it
      // In a complete implementation, we would:
      // 1. Query all recent transactions for this stan
      // 2. Calculate metrics like new orders, revenue, etc.
      // 3. Update the dashboard document with fresh calculations
      
      // Get all transactions for this stan in the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final transactionsSnapshot = await firestore
          .collection(AppConstants.transaksiCollection)
          .where('stanId', isEqualTo: stanId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      // Calculate metrics from transactions
      int newOrders = 0;
      int inProcess = 0;
      int completed = 0;
      double revenue = 0.0;
      final uniqueCustomers = <String>{};
      final itemQuantities = <String, int>{};

      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';
        final siswaId = data['siswaId'] ?? '';
        final finalAmount = (data['finalAmount'] as num?)?.toDouble() ?? 0.0;

        // Count orders by status
        switch (status) {
          case AppConstants.statusBelumDikonfirm:
            newOrders++;
            break;
          case AppConstants.statusDimasak:
          case AppConstants.statusDiantar:
            inProcess++;
            break;
          case AppConstants.statusSampai:
            completed++;
            revenue += finalAmount;
            break;
        }

        // Track unique customers
        if (siswaId.isNotEmpty) {
          uniqueCustomers.add(siswaId);
        }

        // Process order items to track top selling items
        final items = data['items'] as List<dynamic>?;
        if (items != null) {
          for (final item in items) {
            if (item is Map<String, dynamic>) {
              final itemName = item['namaMakanan'] ?? '';
              final qty = (item['qty'] as num?)?.toInt() ?? 0;
              if (itemName.isNotEmpty) {
                itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) + qty;
              }
            }
          }
        }
      }

      // Get total menu items for this stan
      final menuSnapshot = await firestore
          .collection(AppConstants.menuCollection)
          .where('stanId', isEqualTo: stanId)
          .get();
      final totalMenuItems = menuSnapshot.size;

      // Determine top selling items
      final sortedEntries = itemQuantities.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topSellingItems = sortedEntries
          .take(5)
          .map((e) => e.key)
          .toList();

      // Prepare updated dashboard data
      final updatedData = DashboardDataModel(
        id: stanId,
        stanId: stanId,
        newOrders: newOrders,
        inProcess: inProcess,
        completed: completed,
        revenue: revenue,
        totalCustomers: uniqueCustomers.length,
        totalMenuItems: totalMenuItems,
        topSellingItems: topSellingItems,
        monthlyStats: {}, // Would be calculated based on monthly data
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to dashboard collection
      await firestore
          .collection(AppConstants.dashboardCollection)
          .doc(stanId)
          .set(updatedData.toFirestore(), SetOptions(merge: true));

      return updatedData;
    } catch (e) {
      throw ServerFailure('Gagal menyegarkan data dashboard: ${e.toString()}');
    }
  }
}