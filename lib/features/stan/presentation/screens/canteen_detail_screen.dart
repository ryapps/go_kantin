import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';
import 'package:kantin_app/features/stan/presentation/bloc/canteen_detail_bloc.dart';
import 'package:kantin_app/features/stan/presentation/bloc/canteen_detail_event.dart';
import 'package:kantin_app/features/stan/presentation/bloc/canteen_detail_state.dart';

class CanteenDetailScreen extends StatefulWidget {
  final Stan stan;

  const CanteenDetailScreen({super.key, required this.stan});

  @override
  State<CanteenDetailScreen> createState() => _CanteenDetailScreenState();
}

class _CanteenDetailScreenState extends State<CanteenDetailScreen> {
  CanteenDetailLoaded? _lastLoadedState;

  @override
  void initState() {
    super.initState();
    context.read<CanteenDetailBloc>().add(
      LoadCanteenDetailEvent(widget.stan.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<CanteenDetailBloc, CanteenDetailState>(
        listener: (context, state) {
          if (state is StanSwitchConfirmation) {
            showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Ganti Kantin?'),
                content: Text(
                  'Keranjang Anda berisi menu dari ${state.currentStanName}. '
                  'Jika lanjut, keranjang akan dikosongkan.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      context.read<CanteenDetailBloc>().add(
                        SwitchStanEvent(state.newItem),
                      );
                    },
                    child: const Text('Ya'),
                  ),
                ],
              ),
            );
          }
        },
        child: BlocBuilder<CanteenDetailBloc, CanteenDetailState>(
          builder: (context, state) {
            if (state is CanteenDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CanteenDetailEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fastfood, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada menu tersedia',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              );
            }

            if (state is CanteenDetailError) {
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
                        context.read<CanteenDetailBloc>().add(
                          LoadCanteenDetailEvent(widget.stan.id),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is CanteenDetailLoaded) {
              _lastLoadedState = state;
              return Stack(
                children: [
                  _buildMainContent(state),
                  if (state.totalItemsCount > 0)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _buildCartBottomBar(state),
                    ),
                ],
              );
            }

            if (state is StanSwitchConfirmation && _lastLoadedState != null) {
              final previousState = _lastLoadedState!;
              return Stack(
                children: [
                  _buildMainContent(previousState),
                  if (previousState.totalItemsCount > 0)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _buildCartBottomBar(previousState),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(CanteenDetailLoaded state) {
    return CustomScrollView(
      slivers: [
        // Sliver App Bar with Canteen Image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: AppTheme.backgroundColor,
          foregroundColor: AppTheme.textPrimary,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.stan.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Canteen Info Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Canteen Name and Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stan.namaStan,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.stan.namaPemilik,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.stan.rating}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  widget.stan.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                // Location and Time Info
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.location_on,
                        label: widget.stan.location,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.access_time,
                        label:
                            '${widget.stan.openTime} - ${widget.stan.closeTime}',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.phone,
                        label: widget.stan.telp,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Food Section
                _buildMenuSection(
                  title: 'Makanan',
                  items: state.foodItems,
                  context: context,
                  state: state,
                ),
                const SizedBox(height: 24),
                // Beverage Section
                _buildMenuSection(
                  title: 'Minuman',
                  items: state.beverageItems,
                  context: context,
                  state: state,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Menu> items,
    required BuildContext context,
    required CanteenDetailLoaded state,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fastfood, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No items available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          )
        else
          Column(
            children: items.map((item) {
              return _buildMenuItemCard(item, context, state);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMenuItemCard(
    Menu item,
    BuildContext context,
    CanteenDetailLoaded state,
  ) {
    final quantity = state.itemQuantities[item.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.foto,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Menu Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.namaItem,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!item.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Sold Out',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.deskripsi,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isMakanan
                              ? Colors.orange[100]
                              : Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.isMakanan ? 'Makanan' : 'Minuman',
                          style: TextStyle(
                            color: item.isMakanan
                                ? Colors.orange[700]
                                : Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Rp ${item.harga.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Add to Cart / Quantity Counter
                  SizedBox(
                    width: double.infinity,
                    child: quantity == 0
                        ? ElevatedButton(
                            onPressed: item.isAvailable
                                ? () {
                                    context.read<CanteenDetailBloc>().add(
                                      AddItemToCartEvent(item),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              disabledBackgroundColor: Colors.grey[400],
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green[600]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    color: Colors.green[600],
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      context.read<CanteenDetailBloc>().add(
                                        UpdateItemQuantityEvent(
                                          item,
                                          quantity - 1,
                                        ),
                                      );
                                    } else {
                                      context.read<CanteenDetailBloc>().add(
                                        UpdateItemQuantityEvent(item, 0),
                                      );
                                    }
                                  },
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                Text(
                                  '$quantity',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.green[600],
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    context.read<CanteenDetailBloc>().add(
                                      UpdateItemQuantityEvent(
                                        item,
                                        quantity + 1,
                                      ),
                                    );
                                  },
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBottomBar(CanteenDetailLoaded state) {
    return InkWell(
      onTap: () {
        context.push('/checkout');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.totalItemsCount} Item${state.totalItemsCount > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ambil di Kantin ${state.stanName}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp${state.cartTotal.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
