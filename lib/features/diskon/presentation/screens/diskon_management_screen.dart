import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';
import 'package:kantin_app/features/diskon/presentation/bloc/diskon_management_bloc.dart';
import 'package:kantin_app/features/diskon/presentation/bloc/diskon_management_event.dart';
import 'package:kantin_app/features/diskon/presentation/bloc/diskon_management_state.dart';

class DiskonManagementScreen extends StatefulWidget {
  final String stanId;

  const DiskonManagementScreen({super.key, required this.stanId});

  @override
  State<DiskonManagementScreen> createState() => _DiskonManagementScreenState();
}

class _DiskonManagementScreenState extends State<DiskonManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<DiskonManagementBloc>().add(LoadDiskons(widget.stanId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DiskonManagementBloc, DiskonManagementState>(
        listener: (context, state) {
          if (state is DiskonCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Diskon berhasil dibuat'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DiskonUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Diskon berhasil diupdate'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DiskonDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Diskon berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DiskonManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DiskonManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiskonManagementLoaded) {
            return Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primaryColor,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Aktif'),
                      Tab(text: 'Kadaluarsa'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDiskonList(state.diskons),
                      _buildDiskonList(state.activeDiskons),
                      _buildDiskonList(state.expiredDiskons),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is DiskonManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DiskonManagementBloc>().add(
                        LoadDiskons(widget.stanId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Tidak ada data'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDiskonDialog(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Diskon',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDiskonList(List<Diskon> diskons) {
    if (diskons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.discount_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada diskon'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DiskonManagementBloc>().add(LoadDiskons(widget.stanId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diskons.length,
        itemBuilder: (context, index) {
          final diskon = diskons[index];
          return _buildDiskonCard(diskon);
        },
      ),
    );
  }

  Widget _buildDiskonCard(Diskon diskon) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isExpired = diskon.isExpired;
    final isValid = diskon.isValid;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isValid
                        ? Colors.green.withOpacity(0.1)
                        : isExpired
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 16,
                        color: isValid
                            ? Colors.green
                            : isExpired
                            ? Colors.red
                            : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${diskon.persentaseDiskon.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: isValid
                              ? Colors.green
                              : isExpired
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isValid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AKTIF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'KADALUARSA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
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
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDiskonDialog(context, diskon);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, diskon);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              diskon.namaDiskon,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${dateFormat.format(diskon.tanggalAwal)} - ${dateFormat.format(diskon.tanggalAkhir)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDiskonDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final persentaseController = TextEditingController();
    DateTime? tanggalAwal;
    DateTime? tanggalAkhir;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Diskon Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Diskon',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama diskon harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: persentaseController,
                  decoration: const InputDecoration(
                    labelText: 'Persentase (%)',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Persentase harus diisi';
                    }
                    final persentase = double.tryParse(value);
                    if (persentase == null ||
                        persentase <= 0 ||
                        persentase > 100) {
                      return 'Persentase harus 1-100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    tanggalAwal == null
                        ? 'Pilih Tanggal Mulai'
                        : DateFormat('dd MMM yyyy').format(tanggalAwal!),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      tanggalAwal = date;
                      (dialogContext as Element).markNeedsBuild();
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    tanggalAkhir == null
                        ? 'Pilih Tanggal Berakhir'
                        : DateFormat('dd MMM yyyy').format(tanggalAkhir!),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: tanggalAwal ?? DateTime.now(),
                      firstDate: tanggalAwal ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      tanggalAkhir = date;
                      (dialogContext as Element).markNeedsBuild();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate() &&
                  tanggalAwal != null &&
                  tanggalAkhir != null) {
                context.read<DiskonManagementBloc>().add(
                  CreateDiskonEvent(
                    stanId: widget.stanId,
                    namaDiskon: namaController.text,
                    persentaseDiskon: double.parse(persentaseController.text),
                    tanggalAwal: tanggalAwal!,
                    tanggalAkhir: tanggalAkhir!,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditDiskonDialog(BuildContext context, Diskon diskon) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: diskon.namaDiskon);
    final persentaseController = TextEditingController(
      text: diskon.persentaseDiskon.toString(),
    );
    DateTime tanggalAwal = diskon.tanggalAwal;
    DateTime tanggalAkhir = diskon.tanggalAkhir;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Diskon'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Diskon',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: persentaseController,
                  decoration: const InputDecoration(
                    labelText: 'Persentase (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(DateFormat('dd MMM yyyy').format(tanggalAwal)),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: tanggalAwal,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      tanggalAwal = date;
                      (dialogContext as Element).markNeedsBuild();
                    }
                  },
                ),
                ListTile(
                  title: Text(DateFormat('dd MMM yyyy').format(tanggalAkhir)),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: tanggalAkhir,
                      firstDate: tanggalAwal,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      tanggalAkhir = date;
                      (dialogContext as Element).markNeedsBuild();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<DiskonManagementBloc>().add(
                  UpdateDiskonEvent(
                    diskonId: diskon.id,
                    namaDiskon: namaController.text,
                    persentaseDiskon: double.parse(persentaseController.text),
                    tanggalAwal: tanggalAwal,
                    tanggalAkhir: tanggalAkhir,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Diskon diskon) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Diskon'),
        content: Text('Yakin ingin menghapus diskon "${diskon.namaDiskon}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DiskonManagementBloc>().add(
                DeleteDiskonEvent(diskonId: diskon.id, stanId: widget.stanId),
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
