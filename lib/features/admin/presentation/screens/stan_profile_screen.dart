import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/admin/presentation/bloc/stan_profile_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/stan_profile_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/stan_profile_state.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:kantin_app/features/stan/domain/entities/stan.dart';

class StanProfileScreen extends StatefulWidget {
  const StanProfileScreen({super.key});

  @override
  State<StanProfileScreen> createState() => _StanProfileScreenState();
}

class _StanProfileScreenState extends State<StanProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaStanController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _telpController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  bool _isEditing = false;
  bool _isFormInitialized = false;

  String? _pickedImagePath;
  String _currentImageUrl = '';
  String _stanId = '';

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) {
      context.read<StanProfileBloc>().add(LoadStanProfile(auth.user.id));
    }
  }

  void _hydrateForm(Stan stan) {
    if (_isFormInitialized) return;

    _stanId = stan.id;
    _namaStanController.text = stan.namaStan;
    _namaPemilikController.text = stan.namaPemilik;
    _telpController.text = stan.telp;
    _descriptionController.text = stan.description;
    _locationController.text = stan.location;
    _openTimeController.text = stan.openTime;
    _closeTimeController.text = stan.closeTime;
    _currentImageUrl = stan.imageUrl;

    _isFormInitialized = true;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    context.read<StanProfileBloc>().add(
      UpdateStanProfile(
        stanId: _stanId,
        namaStan: _namaStanController.text.trim(),
        namaPemilik: _namaPemilikController.text.trim(),
        telp: _telpController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        openTime: _openTimeController.text.trim(),
        closeTime: _closeTimeController.text.trim(),
        imageUrl: _currentImageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StanProfileBloc, StanProfileState>(
      listener: (context, state) {
        if (state is StanProfileImagePicked) {
          setState(() => _pickedImagePath = state.imagePath);
        }

        if (state is StanProfileUpdateSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          setState(() {
            _isEditing = false;
            _pickedImagePath = null;
            _currentImageUrl = state.stan.imageUrl;
          });
        }
        if (state is StanProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is StanProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StanProfileError && _stanId.isEmpty) {
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
                    final authState = context.read<AuthBloc>().state;
                    if (authState is Authenticated) {
                      context.read<StanProfileBloc>().add(
                        LoadStanProfile(authState.user.id),
                      );
                    }
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is StanProfileLoaded) {
          _hydrateForm(state.stan);
        }

        final isUpdating = state is StanProfileUpdating;
        return Scaffold(
           floatingActionButton: SizedBox(
        width: 110,
        height: 48,
        child: FloatingActionButton(
          onPressed: isUpdating
                ? null
                : () {
                    if (_isEditing) {
                      _save();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
          backgroundColor: AppTheme.primaryColor,
          isExtended: true,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isEditing ? Icons.save : Icons.edit),
              const SizedBox(width: 4),
              Text(_isEditing ? 'Simpan' : 'Edit'),
            ],
          ),
        ),
      ),
          body: Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Stan Image
                   Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _pickedImagePath != null
                                ? FileImage(File(_pickedImagePath!))
                                : (_currentImageUrl.isNotEmpty
                                    ? NetworkImage(_currentImageUrl)
                                    : null) as ImageProvider?,
                            child: _currentImageUrl.isEmpty &&
                                    _pickedImagePath == null
                                ? const Icon(Icons.store, size: 48)
                                : null,
                          ),
                          if (_isEditing && !isUpdating)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: !_isEditing || isUpdating
                            ? null
                            : () => context
                                .read<StanProfileBloc>()
                                .add(const PickStanImage()),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
              
                    // Nama Stan
                    TextFormField(
                      controller: _namaStanController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Stan',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama stan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
              
                    // Nama Pemilik
                    TextFormField(
                      controller: _namaPemilikController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pemilik',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama pemilik wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
              
                    // Telepon
                    TextFormField(
                      controller: _telpController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
              
                    // Lokasi
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: Gedung A Lt. 1',
                      ),
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
              
                    // Jam Operasional
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _openTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Jam Buka',
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                              hintText: '08:00',
                            ),
                            readOnly: true,
                            enabled: _isEditing,
                            onTap: _isEditing
                                ? () => _selectTime(
                                    context,
                                    _openTimeController,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _closeTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Jam Tutup',
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                              hintText: '17:00',
                            ),
                            readOnly: true,
                            enabled: _isEditing,
                            onTap: _isEditing
                                ? () => _selectTime(
                                    context,
                                    _closeTimeController,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
              
                    // Deskripsi
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        hintText: 'Ceritakan tentang stan Anda...',
                      ),
                      maxLines: 4,
                      enabled: _isEditing,
                    ),
                  ],
                ),
              ),
              if (isUpdating)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Menyimpan perubahan...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
