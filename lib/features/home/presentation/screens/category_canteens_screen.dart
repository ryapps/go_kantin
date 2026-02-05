import 'package:flutter/material.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';
import 'package:kantin_app/features/stan/presentation/screens/canteen_detail_screen.dart';

import '../widgets/kantin_stall_card.dart';

/// Screen untuk menampilkan daftar kantin berdasarkan kategori yang dipilih
/// Menggunakan atribut categories dari entity Stan untuk filtering
/// Categories di Stan entity berupa List<String> yang berisi category IDs
class CategoryCanteensScreen extends StatefulWidget {
  final Category category;
  final List<Stan> canteens;
  final List<Category>? allCategories; // Untuk mapping category ID ke nama

  const CategoryCanteensScreen({
    super.key,
    required this.category,
    required this.canteens,
    this.allCategories,
  });

  @override
  State<CategoryCanteensScreen> createState() => _CategoryCanteensScreenState();
}

class _CategoryCanteensScreenState extends State<CategoryCanteensScreen> {
  String _sortBy = 'rating'; // rating, name, distance
  List<Stan> _sortedCanteens = [];

  @override
  void initState() {
    super.initState();
    _sortedCanteens = List.from(widget.canteens);
    _sortCanteens();
  }

  void _sortCanteens() {
    setState(() {
      if (_sortBy == 'rating') {
        _sortedCanteens.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_sortBy == 'name') {
        _sortedCanteens.sort((a, b) => a.namaStan.compareTo(b.namaStan));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canteenCount = _sortedCanteens.length;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        title: Text(
          widget.category.name,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Sort menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortCanteens();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 18,
                      color: _sortBy == 'rating'
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rating Tertinggi',
                      style: TextStyle(
                        color: _sortBy == 'rating'
                            ? AppTheme.primaryColor
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      size: 18,
                      color: _sortBy == 'name'
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nama (A-Z)',
                      style: TextStyle(
                        color: _sortBy == 'name'
                            ? AppTheme.primaryColor
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: canteenCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kantin untuk kategori ini',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Header info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(widget.category.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.category.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$canteenCount Kantin tersedia',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Canteen list
                  Expanded(
                    child: canteenCount == 0
                        ? const SizedBox.shrink()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: canteenCount,
                            itemBuilder: (context, index) {
                              final canteen = _sortedCanteens[index];
                              return Column(
                                children: [
                                  KantinStallCard(
                                    stan: canteen,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CanteenDetailScreen(
                                                stan: canteen,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Info tambahan tentang kategori kantin
                                  if (canteen.categories.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 8,
                                      ),
                                      child: Wrap(
                                        spacing: 6,
                                        children: [
                                          Text(
                                            'Kategori lain:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                          ),
                                          ...canteen.categories
                                              .where(
                                                (catId) =>
                                                    catId != widget.category.id,
                                              )
                                              .take(3)
                                              .map((catId) {
                                                // Cari nama kategori dari ID
                                                String categoryName = catId;
                                                if (widget.allCategories !=
                                                    null) {
                                                  final cat = widget
                                                      .allCategories!
                                                      .firstWhere(
                                                        (c) => c.id == catId,
                                                        orElse: () => Category(
                                                          id: catId,
                                                          name: catId,
                                                          icon: '',
                                                          imageUrl: '',
                                                        ),
                                                      );
                                                  categoryName = cat.name;
                                                }

                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    categoryName,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontSize: 10,
                                                          color: AppTheme
                                                              .primaryColor,
                                                        ),
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
