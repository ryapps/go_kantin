import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/widgets/app_bottom_nav.dart';
import 'package:kantin_app/core/widgets/custom_textfield.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_bloc.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_event.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_state.dart';
import 'package:kantin_app/features/home/presentation/screens/category_canteens_screen.dart';
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
  bool _locationLoaded = false;

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
        title: BlocBuilder<SiswaHomeBloc, SiswaHomeState>(
          builder: (context, state) {
            String city = 'Lokasi';
            String address = 'Memuat lokasi...';

            if (state is SiswaHomeLoaded) {
              city = state.city;
              address = state.address;
            }

            return Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.location_pin, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        address,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
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

            // Load location once when state becomes SiswaHomeLoaded
            if (!_locationLoaded) {
              _locationLoaded = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  print('Screen: Triggering LoadLocationEvent');
                  context.read<SiswaHomeBloc>().add(const LoadLocationEvent());
                }
              });
            }

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
                        categories: state.categories,
                        selectedCategoryId: state.selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          // Cari kategori yang dipilih
                          final selectedCategory = state.categories.firstWhere(
                            (cat) => cat.id == categoryId,
                          );

                          // Filter kantin berdasarkan kategori
                          final filteredCanteens = state.allStalls.where((
                            stan,
                          ) {
                            return stan.categories.contains(categoryId);
                          }).toList();

                          // Navigasi ke halaman baru
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryCanteensScreen(
                                category: selectedCategory,
                                canteens: filteredCanteens,
                                allCategories: state.categories,
                              ),
                            ),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
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
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.push('/all-canteens');
                                  },
                                  child: Text(
                                    'See All',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 144,
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
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    
                                  ],
                                ),
                                Text(
                                  'See All',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 144,
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
