import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_state.dart';
import 'package:kantin_app/features/admin/presentation/screens/menu_form_screen.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';

class MenuManagementScreen extends StatefulWidget {
  final String stanId;

  const MenuManagementScreen({super.key, required this.stanId});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String? _selectedFilter;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Verify that the stan exists before loading menu items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuManagementBloc>().add(LoadMenuItems(widget.stanId));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddMenuDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MenuManagementBloc>(),
        child: MenuFormScreen(
          stanId: widget.stanId,
          onSave: (namaItem, harga, jenis, fotoPath, deskripsi) {
            context.read<MenuManagementBloc>().add(
              AddMenuItem(
                stanId: widget.stanId,
                namaItem: namaItem,
                harga: harga,
                jenis: jenis,
                fotoPath: fotoPath,
                deskripsi: deskripsi,
              ),
            );
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }

  void _showEditMenuDialog(Menu menu) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MenuManagementBloc>(),
        child: MenuFormScreen(
          stanId: widget.stanId,
          menu: menu,
          onSave: (namaItem, harga, jenis, fotoPath, deskripsi) {
            context.read<MenuManagementBloc>().add(
              UpdateMenuItem(
                menuId: menu.id,
                namaItem: namaItem,
                harga: harga,
                jenis: jenis,
                fotoPath: fotoPath,
                deskripsi: deskripsi,
              ),
            );
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Menu menu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Apakah Anda yakin ingin menghapus "${menu.namaItem}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<MenuManagementBloc>().add(DeleteMenuItem(menu.id));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari menu...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<MenuManagementBloc>().add(
                                const SearchMenuItems(''),
                              );
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (query) {
                    context.read<MenuManagementBloc>().add(
                      SearchMenuItems(query),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFilterChip('Semua', null),
                      const SizedBox(width: 20),
                      _buildFilterChip('Makanan', 'makanan'),
                      const SizedBox(width: 20),
                      _buildFilterChip('Minuman', 'minuman'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Menu List
          Expanded(
            child: BlocConsumer<MenuManagementBloc, MenuManagementState>(
              listener: (context, state) {
                if (state is MenuManagementSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (state is MenuManagementError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is MenuManagementLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MenuManagementError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MenuManagementBloc>().add(
                              LoadMenuItems(widget.stanId),
                            );
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is MenuManagementLoaded) {
                  if (state.filteredMenus.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery != null &&
                                    state.searchQuery!.isNotEmpty
                                ? 'Tidak ada menu yang ditemukan'
                                : 'Belum ada menu',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan menu pertama Anda',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: state.filteredMenus.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final menu = state.filteredMenus[index];
                      return _buildMenuCard(menu);
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMenuDialog,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Menu'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? filterValue) {
    final isSelected = _selectedFilter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = filterValue);
        context.read<MenuManagementBloc>().add(FilterMenuByType(filterValue));
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildMenuCard(Menu menu) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEditMenuDialog(menu),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Menu Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: menu.foto.isNotEmpty
                    ? Image.network(
                        menu.foto,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, size: 32),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, size: 32),
                      ),
              ),
              const SizedBox(width: 12),

              // Menu Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            menu.namaItem,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: menu.isAvailable
                                ? AppTheme.successColor.withOpacity(0.1)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            menu.isAvailable ? 'Tersedia' : 'Habis',
                            style: TextStyle(
                              fontSize: 11,
                              color: menu.isAvailable
                                  ? AppTheme.successColor
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: menu.jenis == 'makanan'
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        menu.jenis == 'makanan' ? 'Makanan' : 'Minuman',
                        style: TextStyle(
                          fontSize: 11,
                          color: menu.jenis == 'makanan'
                              ? Colors.orange[800]
                              : Colors.blue[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${menu.harga.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    if (menu.deskripsi.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        menu.deskripsi,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditMenuDialog(menu);
                      break;
                    case 'toggle':
                      context.read<MenuManagementBloc>().add(
                        ToggleMenuAvailability(menu.id, !menu.isAvailable),
                      );
                      break;
                    case 'delete':
                      _showDeleteConfirmation(menu);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          menu.isAvailable
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          menu.isAvailable ? 'Tandai Habis' : 'Tandai Tersedia',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 20,
                          color: AppTheme.errorColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
