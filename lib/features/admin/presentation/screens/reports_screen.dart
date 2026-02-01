import 'package:flutter/material.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/admin/presentation/screens/order_report_screen.dart';
import 'package:kantin_app/features/admin/presentation/screens/revenue_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  final String stanId;

  const ReportsScreen({super.key, required this.stanId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: Icon(Icons.shopping_bag, size: 20),
                  text: 'Laporan Pesanan',
                ),
                Tab(
                  icon: Icon(Icons.payments, size: 20),
                  text: 'Laporan Pendapatan',
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            OrderReportScreen(stanId: stanId),
            RevenueReportScreen(stanId: stanId),
          ],
        ),
      ),
    );
  }
}
