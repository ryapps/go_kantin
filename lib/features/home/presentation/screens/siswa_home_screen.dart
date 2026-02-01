import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/widgets/app_bottom_nav.dart';
import 'package:kantin_app/core/widgets/custom_textfield.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_bloc.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_event.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_state.dart';
import 'package:kantin_app/features/stan/presentation/screens/canteen_detail_screen.dart';

import '../widgets/food_category_grid.dart';
import '../widgets/kantin_stall_card.dart';
import '../widgets/offer_banner.dart';

class SiswaHomeScreen extends StatefulWidget {
  const SiswaHomeScreen({super.key});

  @override
  State<SiswaHomeScreen> createState() => _SiswaHomeScreenState();
}

class _SiswaHomeScreenState extends State<SiswaHomeScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SiswaHomeBloc>().add(const LoadHomeEvent());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(radius: 20, child: Icon(Icons.location_pin, size: 24)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Miami',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Sea Beach of beside',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Icon(
                Icons.notifications_none,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SiswaHomeBloc, SiswaHomeState>(
        builder: (context, state) {
          if (state is SiswaHomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SiswaHomeEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kantin tersedia',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          if (state is SiswaHomeError) {
            print(state.message);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SiswaHomeBloc>().add(const LoadHomeEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SiswaHomeLoaded) {
            final trendingStalls = List.of(state.allStalls)
              ..sort((a, b) => b.rating.compareTo(a.rating));
            final trendingItems = trendingStalls.take(4).toList();
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<SiswaHomeBloc>().add(const RefreshStallsEvent());
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomTextField(
                          controller: searchController,
                          hint: 'Search',
                          height: 60,
                          prefixIcon: Icons.search,
                          borderRadius: 25,
                        ),
                      ),
                      // Food Type Grid
                      FoodCategoryGrid(
                        categories: Category.all,
                        selectedCategoryId: state.selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          context.read<SiswaHomeBloc>().add(
                            SelectCategoryEvent(categoryId),
                          );
                        },
                      ),

                      const SizedBox(),
                      ...state.filteredStalls.map(
                        (stall) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: KantinStallCard(
                            stan: stall,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CanteenDetailScreen(stan: stall),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OfferBanner(),
                      ),

                      const SizedBox(height: 24),
                      const SizedBox(height: 28),

                      // Popular Stall Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kantin Populer',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  'See All',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 250,
                        child: PageView(
                          children: [
                            ...state.allStalls.map(
                              (stan) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: KantinStallCard(
                                  stan: stan,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CanteenDetailScreen(stan: stan),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Trending Stall Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Trending Stall',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timer,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '3.1 mins',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  'See All',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 250,
                        child: PageView(
                          children: [
                            ...trendingItems.map(
                              (stan) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: KantinStallCard(
                                  stan: stan,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CanteenDetailScreen(stan: stan),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<SiswaHomeBloc, SiswaHomeState>(
        builder: (context, state) {
          int currentIndex = 0;
          if (state is SiswaHomeLoaded) {
            currentIndex = state.currentBottomNavIndex;
          }

          return AppBottomNav(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<SiswaHomeBloc>().add(ChangeBottomNavEvent(index));
            },
          );
        },
      ),
    );
  }
}
