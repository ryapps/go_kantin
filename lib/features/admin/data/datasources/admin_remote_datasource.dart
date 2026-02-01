import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/utils/constants.dart';

class AdminRemoteDatasource {
  Future<Map<String, dynamic>> getDashboardSummary(String stanId) async {
    try {
      // Query transaksi hari ini untuk stanId tertentu
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final snapshot = await firestore
          .collection('transaksi')
          .where('stanId', isEqualTo: stanId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .get();
      int newOrders = 0;
      int inProcess = 0;
      int completed = 0;
      double revenue = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';
        if (status == AppConstants.statusBelumDikonfirm) newOrders++;
        if (status == AppConstants.statusDiantar || status == AppConstants.statusDimasak) inProcess++;
        if (status == AppConstants.statusSampai) {
          completed++;
          revenue += (data['finalAmount'] ?? 0).toDouble();
        }
      }
      return {
        'newOrders': newOrders,
        'inProcess': inProcess,
        'completed': completed,
        'revenue': revenue,
      };
    } catch (e) {
      throw ServerFailure(
        'Gagal mengambil data ringkasan dashboard: ${e.toString()}',
      );
    }
  }

  final FirebaseFirestore firestore;
  AdminRemoteDatasource({required this.firestore});

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.customerCollection)
          .get();
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'uid': doc.id, // Use document ID as uid for compatibility
      }).toList();
    } catch (e) {
      throw ServerFailure('Gagal mengambil data customer: ${e.toString()}');
    }
  }
}
